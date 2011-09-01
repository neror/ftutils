GIT=git
REPO_TEMP=/tmp/ftutils_docbuild
GEN_DOCS_DIR=$(REPO_TEMP)/apidocs/html/
DOCS_DEST=docs/api
DOCSET_DEST=$(DOCS_DEST)/docset
JEKYLL=jekyll

clean:
	rm -rf $(REPO_TEMP)

clonetmp: clean
	$(GIT) clone -o master git://github.com/neror/ftutils.git $(REPO_TEMP)

docbuild: clonetmp
	$(MAKE) -C $(REPO_TEMP) docsetpublish

docs: docbuild
	cp -R $(REPO_TEMP)/apidocs/html/ $(DOCS_DEST)
	cp -R $(REPO_TEMP)/apidocs/publish/* $(DOCSET_DEST)

serve:
	$(JEKYLL) --pygments --safe
