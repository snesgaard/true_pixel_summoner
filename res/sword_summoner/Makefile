#partial_hitbox=$(addprefix ./build/, $(notdir $(frames:.png=.lua)))
frames=$(addprefix ./build/, idle.png cast.png attack.png wisp.png goblin.png imp2.png undine.png\
				)
boundries=$(frames:.png=.lua)
info=info.lua
hitbox=hitbox.lua
sheet=sheet.png
nmap=normal.png

script_dir=../../modules
texatlas_script=$(script_dir)/texatlas.py
generate_script=$(script_dir)/generate_animation.py
#normal_script=$(script_dir)/normalmap.py

all: create_build_dirs $(sheet) $(hitbox)

$(hitbox): $(boundries)
	@echo "local data = {\n" > $@
	@cat $(boundries) >> $@
	@echo "}\nreturn data" >> $@

$(sheet): $(frames)
	@python $(texatlas_script) $^ -i $(info) -s $(sheet)
#	@python $(normal_script) $(sheet) $(nmap)

./build/attack.%: ./frame/attack.png
	@python $(generate_script) -t 0.075 -w 128 -e 64 -f $(@:.lua=.png)\
					-l $(@:.png=.lua) $< $(addprefix ./boundry/, $(notdir $<))

./build/cast.%: ./frame/cast.png
	@python $(generate_script) -t 0.2 -w 80 -e 60 -f $(@:.lua=.png)\
					-l $(@:.png=.lua) $< $(addprefix ./boundry/, $(notdir $<))

./build/idle.%: ./frame/idle.png
	@python $(generate_script) -t 0.35 -w 64 -e 64 -f $(@:.lua=.png)\
					-l $(@:.png=.lua) $< $(addprefix ./boundry/, $(notdir $<))

./build/wisp.%: ./frame/wisp.png
	@python $(generate_script) -t 0.15 -w 64 -e 64 -f $(@:.lua=.png)\
					-l $(@:.png=.lua) $< $(addprefix ./boundry/, $(notdir $<))

./build/goblin.%: ./frame/goblin.png
	@python $(generate_script) -t 0.35 -w 64 -e 64 -f $(@:.lua=.png)\
					-l $(@:.png=.lua) $< $(addprefix ./boundry/, $(notdir $<))

./build/imp2.%: ./frame/imp2.png
	@python $(generate_script) -t 0.25 -w 64 -e 64 -f $(@:.lua=.png)\
					-l $(@:.png=.lua) $< $(addprefix ./boundry/, $(notdir $<))

./build/undine.%: ./frame/undine.png
	@python $(generate_script) -t 0.35 -w 64 -e 64 -f $(@:.lua=.png)\
					-l $(@:.png=.lua) $< $(addprefix ./boundry/, $(notdir $<))

create_build_dirs:
	@mkdir -p build

clean:
	@rm -rf build
	@rm -f $(info)
	@rm -f $(hitbox)
	@rm -f $(sheet)
	@rm -f $(nmap)
