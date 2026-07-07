SRC_DIR := src
BUILD_DIR := build
TARGET_DIR := $(HOME)/Library/Music/Scripts

all:
	@mkdir -p $(BUILD_DIR)
	@find "$(SRC_DIR)" -name "*.applescript" -print0 | while IFS= read -r -d '' file; do \
		filename=$$(basename "$$file" .applescript); \
		echo "Compiling: $$filename"; \
		osacompile -o "$(BUILD_DIR)/$$filename.scpt" "$$file"; \
	done

install: all
	@echo "Installing scripts to $(TARGET_DIR)..."
	@mkdir -p "$(TARGET_DIR)"
	@find "$(BUILD_DIR)" -name "*.scpt" -print0 | while IFS= read -r -d '' file; do \
		echo "Copying: $$(basename "$$file")"; \
		cp "$$file" "$(TARGET_DIR)/"; \
	done

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean
