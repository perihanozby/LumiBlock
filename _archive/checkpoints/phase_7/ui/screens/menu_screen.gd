class_name MenuScreen
extends LBScreen

var screen_id:="home"
var column: VBoxContainer
var scroll: ScrollContainer
var controls: Dictionary={}
var labels: Dictionary={}
var rebuilding:=false
var entrance: Tween
var score_tween: Tween

class CompletionRing extends Control:
	var progress:=0.0:
		set(value):
			progress=value
			queue_redraw()
	func _ready() -> void:
		custom_minimum_size=Vector2(80,80)
		if SettingsService.reduce_motion(): progress=1
		else: create_tween().tween_property(self,"progress",1.0,0.5)
	func _draw() -> void:
		var center:=Vector2(40,40)
		draw_arc(center,28,-PI/2,-PI/2+TAU*progress,64,Tokens.SUCCESS,3,true)
		if progress>=0.99:
			draw_line(center+Vector2(-12,0),center+Vector2(-3,10),Tokens.SUCCESS,3,true)
			draw_line(center+Vector2(-3,10),center+Vector2(15,-10),Tokens.SUCCESS,3,true)

func enter(params: Dictionary) -> void:
	super.enter(params)
	rebuild()

func _on_locale_changed() -> void:
	if is_inside_tree(): rebuild()

func rebuild() -> void:
	if rebuilding: return
	rebuilding=true
	if score_tween!=null: score_tween.kill()
	for child in get_children():
		remove_child(child)
		child.queue_free()
	controls.clear()
	labels.clear()
	var modal: bool=screen_id in ["pause","game_over","language_picker"] or parameters.get("modal",false)
	var holder: Control=self
	if modal:
		var scrim:=ColorRect.new()
		scrim.color=Tokens.SCRIM
		add_child(scrim)
		scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var center:=CenterContainer.new()
		add_child(center)
		center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var card:=LBCard.new()
		card.custom_minimum_size=Vector2(minf(344,get_viewport_rect().size.x-32),0)
		center.add_child(card)
		holder=card
	else:
		var safe:=SafeAreaContainer.new()
		add_child(safe)
		safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		holder=safe
	scroll=ScrollContainer.new()
	scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	if modal: scroll.custom_minimum_size=Vector2(minf(312,get_viewport_rect().size.x-64),minf(540,get_viewport_rect().size.y-112))
	holder.add_child(scroll)
	column=VBoxContainer.new()
	column.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation",Tokens.SPACE[2])
	scroll.add_child(column)
	if screen_id not in ["home","pause","game_over","language_picker"]:
		var bar:=LBTopBar.new()
		column.add_child(bar)
		bar.configure(screen_id+".title" if screen_id!="about" else "about.title")
		bar.back_pressed.connect(func(): app.router.back())
	match screen_id:
		"home": _home()
		"daily": _daily()
		"stats": _stats()
		"settings": _settings()
		"pause": _pause()
		"game_over": _game_over()
		"language_picker": _language_picker()
		"about": _about()
		"privacy": _privacy()
	if screen_id in ["pause","confirm","game_over"]:
		if entrance!=null: entrance.kill()
		modulate.a=0
		entrance=create_tween()
		if screen_id=="game_over" and not SettingsService.reduce_motion(): entrance.tween_interval(0.6)
		entrance.tween_property(self,"modulate:a",1.0,0.08 if SettingsService.reduce_motion() else 0.26)
	rebuilding=false

func label(key: String,role: String = "body",value: Variant = null,parent: Node = null) -> Label:
	var node:=Label.new()
	node.theme_type_variation="LB_"+role
	node.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	node.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	node.text=tr(key) if value==null else str(value)
	node.language=LocalizationService.locale
	(parent if parent!=null else column).add_child(node)
	labels[key]=node
	return node

func button(key: String,action: Callable,primary: bool = false,parent: Node = null) -> LBButton:
	var node:=LBButton.new()
	node.text_key=key
	node.name=key.replace(".","_")
	node.variant="primary" if primary else "secondary"
	node.large=primary
	node.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	node.pressed_action.connect(action)
	(parent if parent!=null else column).add_child(node)
	controls[key]=node
	return node

func card() -> VBoxContainer:
	var panel:=LBCard.new()
	column.add_child(panel)
	var content:=VBoxContainer.new()
	panel.add_child(content)
	return content

func _home() -> void:
	var brand:=HBoxContainer.new()
	brand.custom_minimum_size.y=140 if get_viewport_rect().size.y/get_viewport_rect().size.x<1.9 else 200
	column.add_child(brand)
	var mark:=BrandMark.new()
	mark.size_flags_vertical=Control.SIZE_SHRINK_CENTER
	brand.add_child(mark)
	var name_column:=VBoxContainer.new()
	name_column.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	name_column.size_flags_vertical=Control.SIZE_SHRINK_CENTER
	brand.add_child(name_column)
	label("app.name","display_l",null,name_column)
	label("home.tagline","body_s",null,name_column)
	var best:=card()
	label("home.best","overline",null,best)
	var value: int=SaveService.profile.records.best_classic
	label("home.best.value","display_l",LocaleFormat.number(value,LocalizationService.locale) if value>0 else "—",best)
	if value==0: label("home.best_none","caption",null,best)
	if app.resumable("classic"):
		button("home.continue",func(): app.start_game("classic"),true)
		button("home.new_game",func(): app.confirm_new("classic"))
	else: button("home.play",func(): app.play_classic(),true)
	var daily:=card()
	daily.get_parent().gui_input.connect(func(event: InputEvent):
		if event is InputEventScreenTouch and event.pressed: app.show_screen("daily")
		elif event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT: app.show_screen("daily"))
	label("home.daily","title",null,daily)
	label("daily.date","caption",LocaleFormat.date(app.today(),LocalizationService.locale),daily)
	label("daily.mission","body_s",app.mission_text(),daily)
	button("home.daily",func(): app.show_screen("daily"),false,daily)
	var row:=HBoxContainer.new()
	column.add_child(row)
	button("home.stats",func(): app.show_screen("stats"),false,row)
	button("home.settings",func(): app.show_screen("settings"),false,row)
	label("home.footer","caption")
	_fit_brand.call_deferred(brand)

func _fit_brand(brand: Control) -> void:
	if not is_instance_valid(brand) or not brand.is_inside_tree(): return
	var excess:=column.get_combined_minimum_size().y-(get_viewport_rect().size.y-Tokens.MARGIN*2)
	if excess>0: brand.custom_minimum_size.y=maxf(88,brand.custom_minimum_size.y-excess)

func _daily() -> void:
	label("daily.date","title",LocaleFormat.date(app.today(),LocalizationService.locale))
	var mission:=card()
	label("daily.mission","headline",app.mission_text(),mission)
	var saved: Variant=SaveService.profile.sessions.daily
	var completed: bool=SaveService.profile.daily.completed.has(app.today())
	var status: String="daily.status.done" if completed else ("daily.status.progress" if app.resumable("daily") else "daily.status.new")
	label(status,"body",null,mission)
	if completed:
		var record: Dictionary=SaveService.profile.daily.completed[app.today()]
		label("daily.completed.score","display_l",LocaleFormat.number(int(record.score),LocalizationService.locale),mission)
		label("daily.completed.time","body_s",LocaleFormat.duration(record.seconds,LocalizationService.locale),mission)
	if saved is Dictionary and saved.date==app.today():
		var challenge:=DailyChallenge.describe(app.today())
		var progress: int=saved.lines if challenge.template==0 else (saved.score if challenge.template==1 else saved.max_combo)
		label("daily.progress","body",tr("daily.progress").format({"a":progress,"b":challenge.target}),mission)
	label("daily.rules_title","title")
	for key in ["daily.rule1","daily.rule2","daily.rule3"]: label(key,"body_s")
	label("daily.streak","body",tr("daily.streak").format({"n":DailyChallenge.current_streak(SaveService.profile.daily.last_streak_date,SaveService.profile.stats.daily_streak,app.today())}))
	label("daily.best_streak","body",tr("daily.best_streak").format({"n":SaveService.profile.stats.daily_best_streak}))
	var attempts:=0
	for entry in SaveService.profile.history:
		if entry.mode=="daily" and str(entry.get("date",Time.get_date_string_from_unix_time(int(entry.ts))))==app.today(): attempts+=1
	if app.resumable("daily"): attempts+=1
	label("daily.attempts","caption",tr("daily.attempts").format({"n":attempts}))
	var key: String="daily.replay" if completed else ("daily.resume" if app.resumable("daily") else "daily.start")
	button(key,func(): app.start_game("daily",completed),true)

func stat(key: String,value: String) -> void:
	var row:=HBoxContainer.new()
	column.add_child(row)
	label(key,"body",tr(key).format({"n":""}),row)
	var number:=label(key+".value","title",value,row)
	number.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT

func _stats() -> void:
	var data: Dictionary=SaveService.profile
	label("stats.records","title")
	for pair in [["best_classic","stats.best_classic"],["best_daily","stats.best_daily"],["best_combo","stats.best_combo"]]:
		var record:=LBStatCard.new()
		column.add_child(record)
		record.configure(pair[1],LocaleFormat.number(data.records[pair[0]],LocalizationService.locale))
		record.value_label.theme_type_variation="LB_display_l"
		labels[pair[1]+".value"]=record.value_label
	label("stats.totals","title")
	for pair in [["games_finished","stats.games"],["lines_cleared","stats.lines"],["pieces_placed","stats.pieces"],["perfect_clears","stats.perfect"],["daily_completed","stats.daily_done"]]: stat(pair[1],LocaleFormat.number(data.stats[pair[0]],LocalizationService.locale))
	stat("stats.time",LocaleFormat.duration(data.stats.play_seconds,LocalizationService.locale))
	stat("daily.streak",str(DailyChallenge.current_streak(data.daily.last_streak_date,data.stats.daily_streak,app.today())))
	stat("daily.best_streak",str(data.stats.daily_best_streak))
	label("stats.recent","title")
	if data.stats.games_finished+data.stats.games_abandoned==0: label("stats.empty","body_s")
	for entry in data.history.slice(0,10):
		label("history."+str(entry.ts),"body_s",LocaleFormat.date(entry.ts,LocalizationService.locale)+" · "+LocaleFormat.number(entry.score,LocalizationService.locale)+" · "+tr("over.lines")+": "+str(entry.lines))

func toggle(key: String,setting: String) -> void:
	var node:=LBToggle.new()
	node.text_key=key
	node.button_pressed=SettingsService.values[setting]
	node.toggled.connect(func(value): SettingsService.set_value(setting,value))
	column.add_child(node)
	controls[key]=node

func _settings() -> void:
	label("settings.sound","title")
	for setting in ["sfx","music"]:
		toggle("settings."+setting,setting)
		var slider:=LBSlider.new()
		slider.value=SettingsService.values[setting+"_volume"]
		slider.value_changed.connect(func(value): SettingsService.set_value(setting+"_volume",value))
		slider.drag_ended.connect(func(_changed): AudioService.play("toggle"))
		column.add_child(slider)
		controls["settings."+setting+"_volume"]=slider
	label("settings.feel","title")
	toggle("settings.haptics","haptics")
	var effects:=LBSegmented.new()
	column.add_child(effects)
	effects.configure(["settings.effects.minimal","settings.effects.balanced","settings.effects.rich"],["minimal","balanced","rich"],SettingsService.values.effects)
	effects.selected.connect(func(value): SettingsService.set_value("effects",value))
	controls["settings.effects"]=effects
	toggle("settings.reduce_motion","reduce_motion")
	label("settings.gameplay","title")
	toggle("settings.assist","placement_assist")
	toggle("settings.marks","colorblind_marks")
	var text_size:=LBSegmented.new()
	column.add_child(text_size)
	text_size.configure(["settings.text_normal","settings.text_large"],[1.0,1.15],SettingsService.values.text_scale)
	text_size.selected.connect(func(value): SettingsService.set_value("text_scale",value))
	controls["settings.text_size"]=text_size
	button("settings.language",func(): app.language_picker())
	button("settings.how_to",func(): app.show_tutorial(true))
	button("settings.about",func(): app.show_screen("about"))
	button("settings.privacy",func(): app.show_screen("privacy"))
	button("settings.reset",func(): app.confirm_reset()).disabled=SaveService.saving_disabled

func _pause() -> void:
	label("pause.title","headline")
	if SaveService.last_save_succeeded: label("pause.saved","body_s")
	button("pause.resume",func(): app.router.pop_modal(),true)
	button("pause.restart",func(): app.confirm_new(app.session.mode,true))
	button("pause.settings",func(): app.router.push_modal(app.scene("settings"),{"modal":true}))
	button("pause.menu",func(): app.show_screen("home"))

func _game_over() -> void:
	var current: GameSession=app.session
	if app.router.current!=null: app.router.current.modulate=Color(0.6,0.6,0.6,0.6)
	if current.mode=="daily" and current.result=="completed": column.add_child(CompletionRing.new())
	label("over.title" if current.mode=="classic" else ("over.daily.done" if current.result=="completed" else "over.daily.failed"),"headline")
	label("over.score","display_xl",LocaleFormat.number(current.score,LocalizationService.locale))
	if not SettingsService.reduce_motion():
		score_tween=create_tween()
		score_tween.tween_interval(0.6)
		score_tween.tween_method(func(number: int):
			if labels.has("over.score"): labels["over.score"].text=LocaleFormat.number(number,LocalizationService.locale),0,current.score,0.7)
	if app.best_before>0 and current.score>app.best_before: label("over.new_best","body")
	label("over.best","body",tr("over.best").format({"n":SaveService.profile.records.best_daily if current.mode=="daily" else SaveService.profile.records.best_classic}))
	var grid:=GridContainer.new()
	grid.columns=2
	grid.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	column.add_child(grid)
	for pair in [["over.lines",str(current.lines)],["over.combo",str(current.max_combo)],["over.pieces",str(current.pieces)],["over.time",LocaleFormat.duration(current.elapsed_s,LocalizationService.locale)]]:
		var statistic:=LBStatCard.new()
		grid.add_child(statistic)
		statistic.configure(pair[0],pair[1])
		labels[pair[0]+".value"]=statistic.value_label
	button("over.again" if current.mode=="classic" else ("daily.replay" if current.result=="completed" else "over.retry"),func(): app.start_game(current.mode,true),true)
	button("over.menu",func(): app.show_screen("home"))

func _language_picker() -> void:
	label("settings.language","headline")
	button("settings.language_system",func(): LocalizationService.set_language("system"); app.router.pop_modal())
	for i in LocalizationService.LOCALES.size():
		var code: String=LocalizationService.LOCALES[i]
		var native: String=LocalizationService.NATIVE_NAMES[i]
		var node:=button("locale."+code,func(): LocalizationService.set_language(code); app.router.pop_modal())
		node.text_key=""
		node.text=native

func _about() -> void:
	label("about.version","body",tr("about.version").format({"v":ProjectSettings.get_setting("application/config/version"),"c":BuildInfo.VERSION_CODE}))
	button("about.licenses",func():
		if labels.has("license.text"): labels["license.text"].visible=not labels["license.text"].visible
		else: label("license.text","body_s",Engine.get_license_text()))
	label("license.summary","body_s",tr("about.licenses"))

func _privacy() -> void:
	label("privacy.body","body")

func _input(event: InputEvent) -> void:
	if screen_id!="game_over": return
	if (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed):
		if score_tween!=null: score_tween.kill()
		if entrance!=null: entrance.kill()
		modulate.a=1
		if labels.has("over.score"): labels["over.score"].text=LocaleFormat.number(app.session.score,LocalizationService.locale)

func exit() -> void:
	if entrance!=null: entrance.kill()
	if score_tween!=null: score_tween.kill()
