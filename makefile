interpretation.pdf: interpretation.md
	pandoc $< --filter=pandoc-crossref -o $@ --bibliography=interpretation.bib -V geometry:margin=1.5in
