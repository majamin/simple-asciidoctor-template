SRC_DIR := src
BUILD_DIR := build

# Find all .adoc files in SRC_DIR and its subdirectories
SRC_FILES := $(shell find $(SRC_DIR) -name '*.adoc')

# Replace SRC_DIR with BUILD_DIR and change extension to .html, .pdf, and -reveal.html
HTML_FILES := $(patsubst $(SRC_DIR)/%.adoc,$(BUILD_DIR)/%.html,$(SRC_FILES))

# Commands
ASCIIDOCTOR := asciidoctor
ASCIIDOCTOR_PDF := asciidoctor-pdf

# Default target
all: $(HTML_FILES)

# Rule to create regular HTML documents
$(BUILD_DIR)/%.html: $(SRC_DIR)/%.adoc
	@mkdir -p $(dir $@)
	$(ASCIIDOCTOR) $(DIAGRAM_OPTION) -o $@ $<

# Clean up the build directory
clean:
	rm -rf $(BUILD_DIR)

# Phony targets
.PHONY: all clean pdf reveal
