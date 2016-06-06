class window.Neat.Renderer.Basic

  constructor: (@view, @collection, @options) ->
    @collection.bind 'reset',   @_collectionHasBeenReset, @
    @collection.bind 'sort',    @_collectionHasBeenSorted, @
    @collection.bind 'add',     @_modelHasBeenAddedToCollection, @
    @collection.bind 'remove',  @_modelHasBeenRemovedFromCollection, @
    @collection.bind 'change',  @_modelHasBeenChanged, @
    @views = []
    @observer = new Observer()
    @renderTimeout = null

  renderTo: (@$ul) ->
    @views = []
    @_render()

  findViewForModel: (model)->
    @views[@_indexOfViewForModel(model)]

  afterRender: (callback) ->
    @observer.observe "after_render", callback

  _render: ->
    # Doesn't need to render anything else like pagination controls on the view
    # Just needs the @$ul that it should render views to.
    # Debounce render calls, esp. when adding lots of models very quickly.
    clearTimeout(@renderTimeout)
    @renderTimeout = setTimeout =>
      @_renderVisibleModels()
    , 100

  _renderVisibleModels: ->
    visibleModels = @_visibleModels()

    # Remove views that no longer correspond to visible models.
    viewIndex = 0
    while viewIndex < @views.length
      if _.contains(visibleModels, @views[viewIndex].model)
        viewIndex += 1
      else
        @_removeView(viewIndex)

    # Add views for newly-visible models; and coerce views
    # (and their corresponding DOM elements) to show up in
    # the same order as the visible models.
    for model, index in visibleModels
      viewIndex = @_indexOfViewForModel(model)
      if viewIndex >= 0
        @_moveView(viewIndex, index) unless viewIndex is index
      else
        @_insertView @view.buildViewFor(model), index

    @observer.fire "after_render"
    @

  _insertView: (view, newIndex) ->
    view.render()
    $(view.el).insertBeforeChildOrAppendTo @$ul, ".neat-row:eq(#{newIndex})"
    @views.splice(newIndex, 0, view)
    @_viewAddedAt(view, newIndex)

  _moveView: (oldIndex, newIndex) ->
    $el = $ @views[oldIndex].el
    $el.detach().insertBeforeChildOrAppendTo @$ul, ".neat-row:eq(#{newIndex})"

    view = @views.splice(oldIndex, 1)[0]
    @views.splice(newIndex, 0, view)
    @_viewRemovedAt(view, oldIndex)
    @_viewAddedAt(view, newIndex)

  _removeView: (oldIndex) ->
    @views[oldIndex].remove()
    view = @views.splice(oldIndex, 1)[0]
    @_viewRemovedAt(view, oldIndex)



  _viewAddedAt: (view, index) ->
    # do nothing

  _viewRemovedAt: (view, index) ->
    # do nothing



  _visibleModels: ->
    @collection.toArray()

  _indexOfViewForModel: (model)->
    _.findIndex @views, (view)-> view.model.cid is model.cid



  _collectionHasBeenReset: ->
    @_render()

  _collectionHasBeenSorted: ->
    @_render()

  _modelHasBeenAddedToCollection: ->
    @_render()

  _modelHasBeenRemovedFromCollection: ->
    @_render()

  _modelHasBeenChanged: (model) ->
    # do nothing
