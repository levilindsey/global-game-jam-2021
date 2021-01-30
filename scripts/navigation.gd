extends Node

enum {
    SPLASH_PAGE,
    MAIN_MENU_PAGE,
    LEVEL_PAGE,
    PAUSE_PAGE,
    GAME_OVER_PAGE,
}

const _MAIN_THEME := preload("res://assets/main_theme.tres")

# Dictionary<PageType, Page>
onready var pages := {
    SPLASH_PAGE: preload("res://scenes/pages/splash_page.tscn").instance(),
    MAIN_MENU_PAGE: preload("res://scenes/pages/main_menu_page.tscn").instance(),
    LEVEL_PAGE: preload("res://scenes/pages/level_page.tscn").instance(),
    PAUSE_PAGE: preload("res://scenes/pages/pause_page.tscn").instance(),
    GAME_OVER_PAGE: preload("res://scenes/pages/game_over_page.tscn").instance(),
}
var current_page: Page
var previous_page: Page

onready var _main_page_canvas_layer := CanvasLayer.new()
onready var _page_wrapper := PanelContainer.new()

func _ready() -> void:
    _main_page_canvas_layer.layer = 2
    add_child(_main_page_canvas_layer)
    
    _page_wrapper.set_theme(_MAIN_THEME)
    _main_page_canvas_layer.add_child(_page_wrapper)
    
    for page in pages.values():
        page.visible = false
        var parent: Node = self if page is LevelPage else _page_wrapper
        parent.add_child(page)

    _on_size_changed()
    get_viewport().connect( \
            "size_changed", \
            self, \
            "_on_size_changed")

func _on_size_changed() -> void:
    _page_wrapper.rect_size = get_viewport().size

func open(page_type: int) -> void:
    if current_page == pages[page_type]:
        return
    
    previous_page = current_page
    current_page = pages[page_type]
    
    var is_level_page := current_page is LevelPage
    var was_pause_page := previous_page is PausePage
    _page_wrapper.visible = !is_level_page
    get_tree().paused = !is_level_page
    
    current_page.visible = true
    if !was_pause_page:
        current_page._on_activated()
    
    if previous_page != null and !(current_page is PausePage):
        previous_page._on_deactivated()
        previous_page.visible = false
