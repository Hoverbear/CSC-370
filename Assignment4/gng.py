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

def select_queries():
    """
    Display a list of queries and select from them.
    """
    print (
        "== Query Select ==\n"
        "   1 - Balance Sheet\n"
        "   2 - Volunteers\n"
        "   3 - Senior Volunteers\n"
        "   4 - Members\n"
        "   5 - Campaign Organizers\n"
        "   6 - Social Groups\n"
        "   7 - Events by Campaign\n"
        "   8 - Donors\n"
        "   9 - Reimbursement Audit\n"
        "   10 - Campaign Audit\n"
        "   b - Back"
    )
    input = raw_input("Select query: ")
    # Handle input.
    if input == '1':
        return "one"
    elif input == '2':
        return "two"
    elif input == '3':
        return "three"
    elif input == '4':
        return "four"
    elif input == '5':
        return "five"
    elif input == '6':
        return "six"
    elif input == '7':
        return "seven"
    elif input == '8':
        return "eight"
    elif input == '9':
        return "nine"
    elif input == '10':
        return "ten"
    else:
        return None

# Auxilary Functions
def select_all(target):
    cursor.execute("""
    select * from %s;
    """ % (target)) # No risk of injection here.
    for item in cursor.fetchall():
        print item

# Main
def main(argv=None):
    """
    Do what must be done!
    """
    global dbconn, cursor
    if argv is None:
        argv = sys.argv
    # Connect.
    dbconn = psycopg2.connect(host='studentdb.csc.uvic.ca', user='c370_s19', password='eJYbM9CI')
    cursor = dbconn.cursor()
    
    print (
        "== Welcome ==\n"
        "You're now logged into the GnG system."
    )
    # Main program loop.
    while (True):
        # Top level Prompt.
        print (
            "Your options are:\n"
            "   s - Make a custom select statement.\n"
            "   b - Browse Prebuilt Queries.\n"
            "   i - Insert a new item.\n"
            "   u - Update an existing item.\n"
            "   r - Remove an existing item.\n"
            "   q - Quits the program."
        )
        input = raw_input("Select Functionality: ")
        # Handle input.
        if input == 's':
            # Custom select statement.
            print "TODO: This isn't done yet, sorry!"
        elif input == 'b':
            # Browse Queries.
            query = select_queries();
            if query is not None:
                select_all(query)
            else:
                continue
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