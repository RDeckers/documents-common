rwildcard=$(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *, %,$2),$d))
ifeq ($(OS),Windows_NT)
	CHK_DIR_EXISTS = if not exist "$(strip $1)" mkdir "$(strip $1)"
	NUKE = rmdir /s /q
	RM = del $1
	COPY_DIR = xcopy $1 $2 /E /H /Y
	FIX_PATH = $(subst /,\,$1)
else
	CHK_DIR_EXISTS = test -d $1 || mkdir -p $1
	NUKE = rm -r
	RM = rm
	COPY_DIR = cp -rv $1 $2
	FIX_PATH = $1
endif

PROJECT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
PLOTS_DIR := $(PROJECT_DIR)img
PLOTS_PLT := $(call rwildcard, $(PLOTS_DIR), *.plt)
PLOTS_TEX := $(patsubst %.plt, %.tex, $(PLOTS_PLT))

all: $(PLOTS_TEX)
	@echo $(PLOTS_DIR)
	pdflatex -interaction=nonstopmode main.tex
clean:
	$(call RM, *.out)
	$(call RM, *.log)
	$(call RM, *.aux)
	$(call RM, *.pdf)
	$(call RM, $(call FIX_PATH, $(PLOTS_DIR)/*.tex))
$(PLOTS_DIR)/%.tex: $(PLOTS_DIR)/%.plt
	gnuplot -e "output_file='$@';term_type='latex'" -c "$<"
