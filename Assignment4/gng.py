#!/usr/bin/python 
#########################
# File:  gng.py         #
# Name:  Andrew Hobden  #
# StuID: V00788452      #
#########################

# Imports
import sys
import getopt
import psycopg2 # Postgres

# Global Variables
dbconn = None
cursor = None

# Auxilary Functions


# Main
def main(argv=None):
    global dbconn, cursor
    """
    Do what must be done!
    """
    if argv is None:
        argv = sys.argv
    # Connect.
    dbconn = psycopg2.connect(host='studentdb.csc.uvic.ca', user='c370_s19', password='eJYbM9CI')
    cursor = dbconn.cursor()
    
    # Main program loop.
    while (True):
        # Top level Prompt.
        print (
            "Your options are:\n"
            "    's' - Make a custom select statement.\n"
            "    'b' - Browse Prebuilt Queries.\n"
            "    'i' - Insert a new item.\n"
            "    'u' - Update an existing item.\n"
            "    'r' - Remove an existing item.\n"
            "    'q' - Quits the program."
        )
        input = raw_input('Select Command: ')
        # Handle input.
        if input == 's':
            # Custom select statement.
            print "TODO: This isn't done yet, sorry!"
        elif input == 'b':
            # Browse Queries.
            query = select_queries();
            select(query);
        elif input == 'i':
            # Insert items.
            print "Inserting a new item."
        elif input == 'u':
            # Update items.
            print "Updating an exiting item."
        elif input == 'r':
            # Remove items.
            print "Removing an existing item."
        elif input == 'q':
            # Quit
            print "Quitting."
            return 0;

if __name__ == "__main__":
    sys.exit(main())