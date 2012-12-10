"""The configuration file should have kind of the """
from datetime import datetime
from ConfigParser import ConfigParser
from sys import argv

USAGE = "This script accpets just the filename with the schedule"

class Entry(object):
    def __init__(self, time_range, dirname):
        self.dirname = dirname
        self.start, self.end = [ int(i.strip()) for i in time_range.split('-') ]

    def current(self, current_hour):
        """Check if the hour is current.
        """
        return self.start <= current_hour < self.end


if __name__ == '__main__':
    wday = datetime.today().strftime('%A')
    hour = datetime.now().hour
    cp = ConfigParser()
    cp.readfp(open(argv[1]))

    if cp.has_section(wday):
        for e in [Entry(r, d) for r,d in cp.items(wday)]:
            if e.current(hour):
                print e.dirname
                exit(0)

    print "Not found"
