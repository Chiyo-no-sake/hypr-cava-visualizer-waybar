PREFIX ?= /usr/local
BINDIR := $(PREFIX)/bin

.PHONY: install uninstall

install:
	install -Dm755 visualizer-toggle.sh $(DESTDIR)$(BINDIR)/visualizer-toggle
	install -Dm755 visualizer-restart.sh $(DESTDIR)$(BINDIR)/visualizer-restart

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/visualizer-toggle
	rm -f $(DESTDIR)$(BINDIR)/visualizer-restart
