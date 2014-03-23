API = "http://localhost:3000/api"

class User extends Backbone.Model
  urlRoot: "#{API}/user"
class Group extends Backbone.Model
  urlRoot: "#{API}/group"

class Application extends Backbone.Router

  routes:
    '': 'user'
    'groups/new': 'createGroup'
    'groups/:name(/:type)': 'group'
    'login': 'login'

  status: ""

  initialize: ->
    $.ajax
      url: "#{API}/islogin"
    .done (data) =>
      @user = new User()
      @headerView = new HeaderView @user
      @mainView = new MainView @user
      if data.status is true
        id = data.session.id
        Backbone.history.start pushState: on
        @user.id = id
        @user.fetch()
      else
        Backbone.history.start pushState: on
        @navigate "/login", yes

  user: ->
    console.log "user view"
    @mainView.userView.render()

  createGroup: ->

  group: (name, type)->
    @mainView.group name

  login: ->
    console.log "/login"
    console.log @mainView
    @mainView.login()
    console.log "login"

class HeaderView extends Backbone.View
  el: "#header-view"

  initialize: (@user)->
    @listenTo @user, "change", @change
    @groupList = $(".groups")

  append: (user)->
    console.log user

  appendGroupToList: (model)->
    element = $("#group-element")
    template = _.template(element.html())({name: model.name})
    @groupList.append template

  change: (user)->
    @groupList.empty()
    for g in user.get "groups"
      @appendGroupToList g

class MainView extends Backbone.View
  el: "#main-view"

  initialize: (@user)->
    @groupView = new GroupView()
    @userView  = new UserView @user
      

  group: (name)->
    @groupView.model.id = name
    $(@.el).empty()
    @groupView.model.fetch()

  user: ->
    $(@.el).empty()

  login: ->
    $(@.el).empty()
    loginView = new LoginView()
    loginView.render()

  render: (el)->

class LoginView extends Backbone.View
  tagName: "div"
  className: "col-md-6 col-md-offset-3"

  events:
    "click button.login": "login"
    "click button.signup": "signup"
    
  initialize: ->

  login: (e)->
    e.preventDefault()
    id = $(@.el).find(".login-id").val()
    pass = $(@.el).find(".login-pass").val()
    $.ajax
      url: "#{API}/login"
      type: "POST"
      data:
        id: id
        pass: pass
      dataType: "json"
    .done (data)=>
      console.log "logined??"
      console.log data
      if data.status is true
        App.user.id = data.user.id
        App.navigate ""
      else
        window.alert "IDかパスワードが間違ってます"

  signup: (e)->
    e.preventDefault()
    id = $(@.el).find(".login-id").val()
    pass = $(@.el).find(".login-pass").val()
    $.ajax
      url: "#{API}/signup"
      type: "POST"
      data:
        id: id
        pass: pass
      dataType: "json"
    .done (data)=>
      if data.status is true
        window.alert "サインアップ完了！"
        App.navigate "/"
      else
        window.alert "既に利用されています。他のIDをご利用ください。"

  render: ->
    $(@.el).html _.template($("#login-view").html())()
    $("#main-view").html @.el

class UserView extends Backbone.View
  tagName: "div"

  initialize: (@user)->
    @listenTo @user, "change", @change

  change: (model)->
    console.log model

  render: ->
    $("#main-view").html @.el

class GroupView extends Backbone.View
  tagName: "div"
  events:
    "click button.add-member": "addMember"

  initialize: ->
    @model = new Group()
    @listenTo @model, "change", @change

  change: (model)->
    console.log "group model change"
    console.log model
    $(@.el).append _.template($("#group-view-member").html())
      members: model.get "users"
    $(@.el).append _.template($("#group-view-analytics").html())()
    $(@.el).append _.template($("#group-view-program").html())()
    @render()

  render: ->
    $("#main-view").html @.el

  addMember: ->
    console.log "member"

# class Sidebar extends Backbone.View
#   el: ".sidebar"
#   events:
#     "click a": "focus"

#   initialize: (@user)->
#     console.log @user
#     @listenTo @user, "change", @change
#     @groupsView = $(".group-list")

#   focus: (name)->
#     console.log "focus!"
#     console.log @

#   append: (model)->
#     template = _.template $("#sidebar-group-element").html()
#     @groupsView.append template({name: model.name, description: ""})

#   change: (models)->
#     console.log "change!!"
#     @groupsView.empty()
#     console.log models
#     for model in models.get("groups")
#       @append model

#   changeFocus: (target)->
#     $(@.el).find("li").each ->
#       if $(@.el).hasClass target
#         $(@.el).addClass "active"
#       else
#         $(@.el).removeClass "active"

# class MainView extends Backbone.View
#   el: "#main-view"

#   initialize: ->


#   reset: ->
#     $(@.el).empty()

#   setGroupView: (name)->
#     @reset()
#     @group = new Group name
#     groupView = new GroupView()
#     groupView.render()

#   setUserView: ->
#     @reset()

#     userView = new UserView()
#     userView.render()

# class ContentView extends Backbone.View
#   el: "#content-view"

#   intialize: ->


#   change: (model)->
#     $(@.el).empty()

# class UserView extends Backbone.View

#   initialize: (@user)->


#   render: ->
#     template = _.template $("#user-view").html()
#     $("#main-view").html template()

# class GroupView extends Backbone.View

#   initialize: (name)->
#     group = new Group(name)
#     @memberListView = new MemberListView group

#   render: ->
#     console.log "render"
#     template = _.template $("#group-view").html()
#     $("#main-view").html template()

  # getMemberListView: ->
  #   $(@memberListView.el).show()
  #   return @memberListView

# class MemberListView extends Backbone.View

#   initialize: (@group)->
#     @listenTo @group, "change", @change

#   change: (model)->
#     console.log model

$ =>
  window.App = new Application()