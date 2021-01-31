extends Node

enum {
    SPLASH_PAGE,
    MAIN_MENU_PAGE,
    LEVEL_PAGE,
    PAUSE_PAGE,
    GAME_OVER_PAGE,
}

const _MAIN_THEME := preload("res://assets/main_theme.tres")

const _TRANSPARENT_PAGES := [
    PAUSE_PAGE,
    GAME_OVER_PAGE,
]

# Dictionary<PageType, Page>
onready var pages := {
    MAIN_MENU_PAGE: preload("res://scenes/pages/main_menu_page.tscn").instance(),
    LEVEL_PAGE: preload("res://scenes/pages/level_page.tscn").instance(),
    PAUSE_PAGE: preload("res://scenes/pages/pause_page.tscn").instance(),
    GAME_OVER_PAGE: preload("res://scenes/pages/game_over_page.tscn").instance(),
}
var current_page: Page
var previous_page: Page

onready var _main_page_canvas_layer := CanvasLayer.new()
onready var _page_opaque_wrapper := PanelContainer.new()
onready var _page_transparent_wrapper := PanelContainer.new()

func _ready() -> void:
    _main_page_canvas_layer.layer = 2
    add_child(_main_page_canvas_layer)
    
    _page_opaque_wrapper.set_theme(_MAIN_THEME)
    _page_opaque_wrapper.visible = false
    _main_page_canvas_layer.add_child(_page_opaque_wrapper)
    
    _page_transparent_wrapper.set_theme(_MAIN_THEME)
    var transparent_style := StyleBoxFlat.new()
    transparent_style.bg_color = Color.from_hsv(0, 0, 0, 0.2)
    _page_transparent_wrapper.add_stylebox_override("panel", transparent_style)
    _page_transparent_wrapper.visible = false
    _main_page_canvas_layer.add_child(_page_transparent_wrapper)
    
    for page_type in pages:
        var page: Page = pages[page_type]
        page.visible = false
        var parent: Node = (
                self if 
                page_type == LEVEL_PAGE else 
                (_page_transparent_wrapper if 
                _TRANSPARENT_PAGES.find(page_type) >= 0 else 
                _page_opaque_wrapper))
        parent.add_child(page)

    _on_size_changed()
    get_viewport().connect( \
            "size_changed", \
            self, \
            "_on_size_changed")

func _on_size_changed() -> void:
    _page_opaque_wrapper.rect_size = get_viewport().size
    _page_transparent_wrapper.rect_size = get_viewport().size

func open(page_type: int) -> void:
    if current_page == pages[page_type]:
        return
    
    previous_page = current_page
    current_page = pages[page_type]
    
    var is_level_page := current_page is LevelPage
    var is_transparent_page := _TRANSPARENT_PAGES.find(page_type) >= 0
    var was_pause_page := previous_page is PausePage
    _page_opaque_wrapper.visible = !is_level_page and !is_transparent_page
    _page_transparent_wrapper.visible = !is_level_page and is_transparent_page
    get_tree().paused = !is_level_page
    
    current_page.visible = true
    if !was_pause_page:
        current_page._on_activated()
    
    if previous_page != null and !is_transparent_page:
        previous_page._on_deactivated()
        previous_page.visible = false

func get_level_page() -> LevelPage:
    return pages[LEVEL_PAGE]
