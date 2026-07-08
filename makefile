SRC_DIR := src
BUILD_DIR := build
TARGET_DIR := $(HOME)/Library/Music/Scripts

SOURCES := $(shell find $(SRC_DIR) -name "*.applescript")
SCRIPTS := $(patsubst $(SRC_DIR)/%.applescript,$(BUILD_DIR)/%.scpt,$(SOURCES))

all: $(SCRIPTS)

$(BUILD_DIR)/%.scpt: $(SRC_DIR)/%.applescript
	@mkdir -p $(dir $@)
	@echo "Compiling: $<"
	osacompile -o "$@" "$<"


install: all
	@echo "Installing scripts to $(TARGET_DIR)..."
	@mkdir -p "$(TARGET_DIR)"
	@cp $(SCRIPTS) "$(TARGET_DIR)/"


clean:
	rm -rf $(BUILD_DIR)


.PHONY: all install clean