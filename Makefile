PREFIX     ?= /usr
SYSCONFDIR ?= /etc
LIBDIR     ?= $(PREFIX)/lib
UNITDIR    ?= $(LIBDIR)/systemd/system
DATADIR    ?= $(LIBDIR)/bluetooth-autoconnect
UDEVDIR    ?= $(LIBDIR)/udev/rules.d


ifdef NO_DESTDIR_IN_POST_INSTALL
SYSCONFDIR_IN_POST_INSTALL=$(SYSCONFDIR)/default/bluetooth-autoconnect
else
SYSCONFDIR_IN_POST_INSTALL=$(DESTDIR)$(SYSCONFDIR)/default/bluetooth-autoconnect
endif

.PHONY: all install uninstall

all:
	@echo "Nothing to build. Run 'make install' as root."
	@echo
	@echo "The following files will be installed:"
	@echo "bluetooth-autoconnect.sh       -> $(DESTDIR)$(DATADIR)/bluetooth-autoconnect.sh"
	@echo "bluetooth-autoconnect.service  -> $(DESTDIR)$(UNITDIR)/bluetooth-autoconnect.service"
	@echo "bluetooth-autoconnect.rules    -> $(DESTDIR)$(UDEVDIR)/61-bluetooth-autoconnect.rules"
	@echo "bluetooth-autoconnect-defaults -> $(DESTDIR)$(SYSCONFDIR)/default/bluetooth-autoconnect"

install:
	install -Dm755 bluetooth-autoconnect.sh        $(DESTDIR)$(DATADIR)/bluetooth-autoconnect.sh
	install -Dm644 bluetooth-autoconnect.service   $(DESTDIR)$(UNITDIR)/bluetooth-autoconnect.service
	install -Dm644 bluetooth-autoconnect.rules     $(DESTDIR)$(UDEVDIR)/61-bluetooth-autoconnect.rules
	install -Dm644 bluetooth-autoconnect-defaults  $(DESTDIR)$(SYSCONFDIR)/default/bluetooth-autoconnect
	@echo
	@echo
	@echo "            [POST INSTALL]"
	@echo
	@echo "Update the $(SYSCONFDIR_IN_POST_INSTALL) file, then reload systemd and udev"
	@echo
	@echo "sudoedit $(SYSCONFDIR_IN_POST_INSTALL)"
	@echo "sudo systemctl daemon-reload"
	@echo "sudo udevadm control --reload-rules"
	@echo

uninstall:
	rm -f $(DESTDIR)$(DATADIR)/bluetooth-autoconnect.sh
	rm -f $(DESTDIR)$(UNITDIR)/bluetooth-autoconnect.service
	rm -f $(DESTDIR)$(UDEVDIR)/61-bluetooth-autoconnect.rules
	rm -f $(DESTDIR)$(SYSCONFDIR)/default/bluetooth-autoconnect
	-rmdir $(DESTDIR)$(DATADIR) 2>/dev/null || true
	@echo
	@echo
	@echo "        [POST UNINSTALL]"
	@echo
	@echo "sudo udevadm control --reload-rules"
	@echo
