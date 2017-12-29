#partial_hitbox=$(addprefix ./build/, $(notdir $(frames:.png=.lua)))
frames=$(addprefix ./build/, wisp1.png wisp2.png\
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

./build/%:
	@python $(generate_script) \
					--info $(@:.png=.lua) --frame $(@:.lua=.png)\
					$(notdir $(@:.png= ))

create_build_dirs:
	@mkdir -p build

clean:
	@rm -rf build
	@rm -f $(info)
	@rm -f $(hitbox)
	@rm -f $(sheet)
	@rm -f $(nmap)
