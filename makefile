interpretation.pdf: interpretation.md interpretation.bib
	pandoc $< --filter=pandoc-crossref -o $@ --bibliography=interpretation.bib -V geometry:margin=1.5in

pd.png pi.png tree.png: examples.R
	Rscript examples.R
