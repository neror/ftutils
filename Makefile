XCODEBUILD ?= xcodebuild
SIMULATOR_SDK ?= iphonesimulator4.0
DEVICE_SDK ?= iphoneos4.0
BUILD_TARGET ?= FTUtils
BUILD_ARGS=-target $(BUILD_TARGET) -sdk $(SIMULATOR_SDK) -configuration

CLOC ?= $(HOME)/Work/cloc-1.07.pl
CLOC_ARGS=--force-lang="Objective C",m --exclude-dir=Support,build,.git,Tests,Classes/GameObjects,../../iphone --no3

APPLEDOC ?= appledoc
APPLEDOC_TEMPLATE_DIR ?= apidocs/.templates
APPLEDOC_OPTS = --output apidocs \
								--templates $(APPLEDOC_TEMPLATE_DIR) \
								--project-name FTUtils \
								--project-version $(shell cat VERSION) \
								--project-company "Free Time Studios, LLC" \
								--company-id com.freetimestudios \
								--create-html \
								--no-create-docset \
								--no-install-docset \
								--no-publish-docset \
								--keep-intermediate-files \
								--verbose 0
APPLEDOC_EXTRA_OPTS ?= 

all: cleandebug test

cleandocs:
	rm -rf apidocs/html
	rm -rf apidocs/docset
	rm -rf apidocs/publish

docs: cleandocs
	$(APPLEDOC) $(APPLEDOC_OPTS) $(APPLEDOC_EXTRA_OPTS) Headers

docset: cleandocs
	$(APPLEDOC) $(APPLEDOC_OPTS) --create-docset $(APPLEDOC_EXTRA_OPTS) Headers
	
docsetinstall: cleandocs
	$(APPLEDOC) $(APPLEDOC_OPTS) --create-docset --install-docset $(APPLEDOC_EXTRA_OPTS) Headers
	
docsetpublish: cleandocs
	$(APPLEDOC) $(APPLEDOC_OPTS) 	--create-docset \
																--install-docset \
															 	--publish-docset \
																--docset-feed-url http://ftutils.com/docs/api/docset/%DOCSETATOMFILENAME \
																--docset-package-url  http://ftutils.com/docs/api/docset/%DOCSETPACKAGEFILENAME \
																$(APPLEDOC_EXTRA_OPTS) Headers

clean: cleandebug cleanrelease

count:
	$(CLOC) $(CLOC_ARGS) .

countfile:
	$(CLOC) $(CLOC_ARGS) --by-file .

debug:
	$(XCODEBUILD) $(BUILD_ARGS) Debug
	
release:
	$(XCODEBUILD) $(BUILD_ARGS) Release
	
devicerelease:
	$(XCODEBUILD) -target $(BUILD_TARGET) -sdk $(DEVICE_SDK) -configuration Release

cleandebug:
	$(XCODEBUILD) $(BUILD_ARGS) Debug clean

cleanrelease:
	$(XCODEBUILD) $(BUILD_ARGS) Release clean

