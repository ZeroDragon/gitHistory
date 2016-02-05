fs = require 'fs'
async = require 'async'
spawn = require('child_process').spawn
Table = require 'cli-table'
program = require 'commander'

traeLogs = (original,cb)->
	if original.indexOf(',') isnt -1
		original = original.split(',').map (e)->
			e+='/' if e[-1..] isnt '/'
			return e.trim()
	exclude = [
		'node_modules'
		'bower_components'
	]
	logs = []
	logger = async.queue (repo,callback)->
		command = """
			--git-dir #{repo} --no-pager log --pretty=format:'%an\t%s\t%at\t%ae'
		"""
		theLog = spawn('git',command.split(' '))
		txtLog = ''
		theLog.stdout.on('data',(data)-> txtLog += data)
		theLog.on 'close', (code)->
			repoLog = txtLog.split('\n').filter((e)-> e isnt '').map (e)->
				e = e[1...-1].split('\t')
				return {
					author : e[0]
					email : e[3]
					message : e[1]
					timestamp : ~~e[2]
					repo :repo.replace('/.git','').split('/').pop()
				}
			for item in repoLog
				logs.push item
			callback()
	,100

	caminador = async.queue (path,callback)->
		items = fs.readdirSync path
		for item in items
			if item is '.git'
				logger.push path+item
			else
				if fs.lstatSync(path+item).isDirectory()
					if exclude.indexOf(item) is -1 and item[0] isnt '.'
						caminador.push path+item+'/'
		callback()
	,100

	logger.drain = ->
		if caminador.length() + caminador.running() + logger.length() + logger.running() is 0
			cb logs

	caminador.push original

program
	.option('-r, --repo [string]', 'The path to the repo or where all the repos are')
	.option('-o, --orderby [string]','Order by [commits|recent], default: commits')
	.parse process.argv

unless program.repo?
	program.help()

unless program.orderby?
	program.orderby = 'commits'

traeLogs program.repo, (logs)->
	authors = {}
	for item in logs
		authors[item.author] ?= {commits:0,recent:null,repo:item.repo,message:item.message}
		authors[item.author].commits++
		authors[item.author].email = item.email
		unless authors[item.author].recent?
			authors[item.author].recent = item.timestamp
		else
			if authors[item.author].recent < item.timestamp
				authors[item.author].recent = item.timestamp
				authors[item.author].repo = item.repo
				authors[item.author].message = item.message

	order = []

	for own k,v of authors
		v.name = k
		order.push v

	order.sort (a,b)-> b[program.orderby] - a[program.orderby]

	table = new Table({
		chars: { 'top': '' , 'top-mid': '' , 'top-left': '' , 'top-right': '', 'bottom': '' , 'bottom-mid': '' , 'bottom-left': '' , 'bottom-right': '', 'left': '' , 'left-mid': '' , 'mid': '' , 'mid-mid': '', 'right': '' , 'right-mid': '' , 'middle': ' ' },
		style: { 'padding-left': 0, 'padding-right': 0 }
	})
	table.push ['Usuario','Commits','Last commit','Repo','Last words']
	d = (epoch)->
		addZ = (i)-> ('00'+i).slice(-2)
		dd = new Date epoch*1000
		"""#{dd.getFullYear()}-#{addZ(dd.getMonth()+1)}-#{addZ(dd.getDate())}"""
	for item in order
		table.push [item.name,item.commits,d(item.recent),item.repo,item.message]
	
	console.log ''
	console.log table.toString()