SCAN_BUILD=$(HOME)/Work/iphone/checker-224/scan-build
SCAN_ARGS=-analyze-headers -k -v -checker-cfref -warn-dead-stores -warn-objc-methodsigs -warn-objc-missing-dealloc -warn-objc-unused-ivars
XCODEBUILD=xcodebuild
SIMULATOR_SDK=iphonesimulator3.0
DEVICE_SDK=iphoneos3.0
BUILD_TARGET=FTUtils
BUILD_ARGS=-target $(BUILD_TARGET) -sdk $(SIMULATOR_SDK) -configuration
DOXYGEN=doxygen

CLOC=$(HOME)/Work/cloc-1.07.pl
CLOC_ARGS=--force-lang="Objective C",m --exclude-dir=Support,build,.git,Tests,Classes/GameObjects,../../iphone --no3

all: cleandebug test

docs:
	mkdir -p apidocs
	$(DOXYGEN) Doxyfile

docset: docs
	$(MAKE) -C apidocs/html docset
	
docsetinstall: docs
	$(MAKE) -C apidocs/html install
	
scan: cleandebug scandebug

clean: cleandebug cleanrelease

scanviewdbg:
	$(SCAN_BUILD) $(SCAN_ARGS) --view $(XCODEBUILD) $(BUILD_ARGS) Debug

scanviewrel:
	$(SCAN_BUILD) $(SCAN_ARGS) --view $(XCODEBUILD) $(BUILD_ARGS) Release

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

scandebug:
	$(SCAN_BUILD) $(SCAN_ARGS) $(XCODEBUILD) $(BUILD_ARGS) Debug

scanrelease:
	$(SCAN_BUILD) $(SCAN_ARGS) $(XCODEBUILD) $(BUILD_ARGS) Release

cleandebug:
	$(XCODEBUILD) $(BUILD_ARGS) Debug clean

cleanrelease:
	$(XCODEBUILD) $(BUILD_ARGS) Release clean

