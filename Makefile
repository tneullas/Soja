# to run a test from the test directory, e.g. tests/test_xx.coffee, type "make test_xx" or "make soda_xx" if soda is necessary
# to launch an example from the tutorial 0, "make tuto_0_coffee" (for the coffee version) or "make tuto_0_js" (for the javascript version)
# xdotool is used to switch to an already existing window (to avoid respawing a browser for each launch)
browser = google-chrome
xdotool = xdotool

all: compilation

srv: Soda
	make -C Soda
	mkdir -p compilations
	Soda/Celo/listener_generator -b gen -e Soda/src/parsers/http_cmp_parser.sipe -a HttpRequest_Public -o compilations/dl_req.so -I Soda/src/Soda

# see tests directory to see possible targets
test_%: compilation
	${xdotool} search __gen/${@}__ windowactivate key F5 || ${browser} gen/$@.html

# same s test but launched with Soda
soda_%: compilation
	Soda/soda -nu -hd gen --start-page /test_$*.html
	
Soda:
	git clone git@sc1.ens-cachan.fr:Sodat Soda

.PHONY: compilation
compilation:
	python bin/make.py
