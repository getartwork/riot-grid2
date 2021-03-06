datagen = require './mockdata'

griddata = datagen(1000)
gridheight = 500
require 'es5-shim' #needed for phantom js
window.riot = require 'riot'
require '../lib/grid2.js'
require './testtag.tag'
simulant = require 'simulant'

spyclick = null
columns = []
test = {}
rows = null

# id:i,first_name:randFirstname(),surname:randSurname(),age:randAge()

columns = [
  {field:"id",label:"#",width:20,fixed:true}
  {field:"first_name",label:"First Name",width:100}
  {field:"surname",label:"Surname",width:100}
  {field:"age",label:"Age",width:100}
]

describe 'grid2',->

  beforeEach ->
    startTime = new Date().getTime()
    @domnode = document.createElement('div')
    @domnode.appendChild(document.createElement('testtag'))
    @node = document.body.appendChild(@domnode)
    spyclick = sinon.spy()
    @tag = riot.mount('testtag',{griddata:griddata,columns:columns,gridheight:gridheight,testclick:spyclick})[0]
    riot.update()
    rows = document.querySelectorAll('.gridrow')

  afterEach ->
    @tag.unmount()
    @domnode = ''

  it "should add grid to the document",->
    expect(document.querySelectorAll('testtag').length).to.equal(1)
    expect(document.querySelectorAll('grid2').length).to.equal(1)

  it "should load data into the grid",->
    expect(document.querySelectorAll('.cell').length).to.be.gt(1)
    expect(@node.textContent).to.contain(griddata[0].first_name)
    expect(@node.innerHTML).to.contain(griddata[0].surname)

   it "should render only enough cells needed",->
     expect(document.querySelectorAll('.cell').length).to.be.lt((gridheight/40)*4)
     expect(document.querySelectorAll('.cell').length).to.be.gt((gridheight/40)*3)

  it "should render only enough rows after scrolling",->
    document.querySelector('#overlay').scrollTop = 1000
    expect(document.querySelectorAll('.cell').length).to.be.lt((gridheight/40)*4)
    expect(document.querySelectorAll('.cell').length).to.be.gt((gridheight/40)*3)
   
  it "should render only enough rows after scrolling (again)",->
    document.querySelector('.gridbody').scrollTop = 4389
    expect(document.querySelectorAll('.cell').length).to.be.lt((gridheight/40)*4)
    expect(document.querySelectorAll('.cell').length).to.be.gt((gridheight/40)*3)
 
  it "should change class to active when cell is clicked",->
    expect(@domnode.querySelectorAll('.active').length).to.equal(0)
    simulant.fire(document.querySelector('.cell'),'click')
    expect(@domnode.querySelectorAll('.active').length).to.equal(columns.length)

  it "should only select one row at a time without meta key",->
    expect(@domnode.querySelectorAll('.active').length).to.equal(0)
    simulant.fire(document.querySelector('.cell'),'click')
    expect(@domnode.querySelectorAll('.active').length).to.equal(columns.length)
    simulant.fire(document.querySelectorAll('.cell')[12],'click')
    expect(@domnode.querySelectorAll('.active').length).to.equal(columns.length)

  it "should toggle a row if clicked twice with meta key",->
    expect(@domnode.querySelectorAll('.active').length).to.equal(0)
    simulant.fire(document.querySelectorAll('.cell')[5],'click',{metaKey:true})
    expect(@domnode.querySelectorAll('.active').length).to.equal(columns.length)
    simulant.fire(document.querySelectorAll('.cell')[5],'click',{metaKey:true})
    expect(@domnode.querySelectorAll('.active').length).to.equal(0)

  it "should call onclick on row when cell is clicked",->
    simulant.fire(document.querySelector('.cell'),'click')
    expect(spyclick.calledOnce).to.be.true
    expect(spyclick.args[0][0][0]).to.eql(griddata[0])

  it "should deselect row if meta-clicked",->
    simulant.fire(document.querySelector('.cell'),'click')
    expect(@domnode.querySelectorAll('.active').length).to.equal(columns.length)
    simulant.fire(document.querySelector('.cell'),'click',{metaKey:true})
    expect(@domnode.querySelectorAll('.active').length).to.equal(0)
  
  it "should show custom tag",->
    expect(@domnode.querySelectorAll('.testcell').length).to.equal(0)
    columns[1].tag = "testcell"
    @tag.unmount(true)
    @tag = riot.mount('testtag',{griddata:griddata,columns:columns,gridheight:gridheight,testclick:spyclick})[0]
    riot.update() 
    expect(@domnode.querySelectorAll('.testcell').length).to.be.gt(1)

  it "should pass events through overlay to grid below",->
    e = document.createEvent('MouseEvents')
    # e = simulant( 'click' )
    #e.initMouseEvent(type, canBubble, cancelable, view, detail, screenX, screenY, clientX, clientY)...
    if document.createEvent
      e.initMouseEvent('click', true, true, window, 1, 100, 50, 100, 50)
    simulant.fire(document.querySelector('#overlay'),e)
    expect(spyclick.calledOnce).to.be.true
    expect(spyclick.args[0][0][0]).to.eql(griddata[0])


# it "should call ondblclick callback when row is double clicked",->
#   simulant.fire(document.querySelectorAll('.gridrow')[2],'dblclick')
#   expect(spyclick2.calledOnce).to.be.true
#   expect(spyclick2.args[0][0]).to.eql(griddata[2])

#   it "should select next item when down key is pressed",->
#     simulant.fire(rows[0],'click')
#     document.querySelector('grid').focus()
#     expect(@domnode.querySelector('.active')).to.equal(rows[0])
#     simulant.fire(document,'keydown',{keyCode:40})
#     expect(@domnode.querySelector('.active')).to.equal(rows[1])

#   it "should select next item when down key is pressed",->
#     simulant.fire(rows[0],'click')
#     document.querySelector('grid').focus()
#     expect(@domnode.querySelector('.active')).to.equal(rows[0])
#     simulant.fire(document,'keydown',{keyCode:40})
#     expect(@domnode.querySelector('.active')).to.equal(rows[1])

#   it "should select previous item when up key is pressed",->
#     simulant.fire(rows[3],'click')
#     document.querySelector('grid').focus()
#     expect(@domnode.querySelector('.active')).to.equal(rows[3])
#     simulant.fire(document,'keydown',{keyCode:38})
#     expect(@domnode.querySelector('.active')).to.equal(rows[2])
#     simulant.fire(document,'keydown',{keyCode:38})
#     expect(@domnode.querySelector('.active')).to.equal(rows[1])
#     simulant.fire(document,'keydown',{keyCode:38})
#     expect(@domnode.querySelector('.active')).to.equal(rows[0])

#   it "should not change on keypress if not focused",->
#     simulant.fire(rows[2],'click')
#     expect(@domnode.querySelector('.active')).to.equal(rows[2])
#     simulant.fire(document,'keydown',{keyCode:38})
#     expect(@domnode.querySelector('.active')).to.equal(rows[2])

#   it "should fire onchange on keypress",->
#     simulant.fire(rows[3],'click')
#     document.querySelector('grid').focus()
#     expect(@domnode.querySelector('.active')).to.equal(rows[3])
#     simulant.fire(document,'keydown',{keyCode:38})
#     expect(spyChange.calledTwice).to.be.true

#   it "should select multiple and all in between with shift click",->
#     simulant.fire(rows[3],'click')
#     simulant.fire(rows[5],'click',{shiftKey:true})
#     expect(spyChange.calledTwice).to.be.true
#     expect(@domnode.querySelector('.active')).to.equal(rows[3])
#     expect(spyChange.args[1][0].length).to.equal(3)

#   it "should add one at a time if meta-clicked",->
#     simulant.fire(rows[3],'click')
#     simulant.fire(rows[5],'click',{metaKey:true})
#     expect(@domnode.querySelectorAll('.active').length).to.equal(2)
#     expect(spyChange.args[1][0]).to.eql([griddata[3],griddata[5]])

 
#   it "should select multiple with shift+arrow keys",->
#     simulant.fire(rows[3],'click')
#     document.querySelector('grid').focus()
#     expect(@domnode.querySelectorAll('.active').length).to.equal(1)
#     simulant.fire(document,'keydown',{keyCode:38,shiftKey:true})
#     expect(@domnode.querySelectorAll('.active').length).to.equal(2)

# describe 'grid without data',->

#   beforeEach ->
#     startTime = new Date().getTime()
#     @domnode = document.createElement('div')
#     @domnode.appendChild(document.createElement('testtag2'))
#     @node = document.body.appendChild(@domnode)
#     spyclick = sinon.spy()
#     spyclick2 = sinon.spy()
    
#   afterEach ->
#     @tag.unmount()
#     @domnode = ''

#   it "should add grid without data",->
#     @tag = riot.mount('testtag2',{gridheight:gridheight,testclick:spyclick,testclick2:spyclick2})[0]
#     riot.update()
#     expect(document.querySelectorAll('testtag2').length).to.equal(1)
#     expect(document.querySelectorAll('grid').length).to.equal(1)
#     expect(document.querySelectorAll('.gridrow').length).to.equal(0)

#   it "should not hightlight without a callback function",->
#     @tag = riot.mount('testtag2',{griddata:griddata,gridheight:gridheight,testclick2:spyclick2})[0]
#     riot.update()   
#     expect(@domnode.querySelectorAll('.active').length).to.equal(0)
#     simulant.fire(document.querySelector('.gridrow'),'click')
#     expect(@domnode.querySelectorAll('.active').length).to.equal(0)

#   it "should not hightlight on double click without a callback function",->
#     @tag = riot.mount('testtag2',{griddata:griddata,gridheight:gridheight,testclick2:spyclick2})[0]
#     riot.update()   
#     expect(@domnode.querySelectorAll('.active').length).to.equal(0)
#     simulant.fire(document.querySelector('.gridrow'),'dblclick')
#     expect(@domnode.querySelectorAll('.active').length).to.equal(0)

#   it "should set active rows if passed in",->
#     @tag = riot.mount('testtag2',{griddata:griddata,gridheight:gridheight,activerow:[griddata[1]]})[0]
#     riot.update()   
#     expect(@domnode.querySelectorAll('.active').length).to.equal(1)

#   it "should set multiple active rows if passed in",->
#     @tag = riot.mount('testtag2',{griddata:griddata,gridheight:gridheight,activerow:[griddata[1],griddata[3],griddata[5]]})[0]
#     riot.update()   
#     expect(@domnode.querySelectorAll('.active').length).to.equal(3)
