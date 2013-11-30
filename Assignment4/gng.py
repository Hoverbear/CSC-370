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

############################################
# Queries                                  #
############################################

def select_queries():
  """
  Display a list of queries and select from them.
  """
  #
  print (
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

def select_a_table():
  """
  Prints a list of tables to select from.
  """
  #
  print "== Table Select =="
  cursor.execute("""
  SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_type <> 'VIEW';
  """)
  options = []
  for i, table in enumerate(cursor.fetchall()):
    options.append(table[0])
    print "   {} - {}".format(i, table[0])
  return options[int(raw_input("Select a table to insert into: "))]

############################################
# Auxilary Functions                       #
############################################

def select_all(target):
  """
  Selects all from a given table of query, printing them out nicely.
  """
  #
  cursor.execute("""
  SELECT * FROM %s;
  """ % (target)) # No risk of injection here.
  return {'schema': [desc[0] for desc in cursor.description], 'data': cursor.fetchall()}

def print_as_table(schema, results):
  """
  Prints the given Schema and results as a table.
  """
  # Get the Table Descriptors.
  schemaString = ''.join(["{:^25}|".format(i) for i in schema])
  print schemaString
  print '-' * len(schemaString)
  # Print out the items.
  for item in results:
    print ''.join(["{:^25}|".format(i) for i in item])

def custom_statement():
  print "(This is a dangerous action!)"
  command = raw_input("Enter your custom SQL string: ")
  cursor.execute(command);
  for item in cursor.fetchall():
    print item
  return

############################################
# Supporters                               #
############################################

def supporter_management():
  print (
    "Your options are:\n"
    "   v - View details about a supporter.\n"
    "   a - Add a supporter.\n"
    "   m - Modify a supporter.\n"
    "   d - Delete a supporter.\n"
    "   b - Go back home."
  )
  command = raw_input("Select Functionality: ")
  # Handle input.
  if command == 'v':
    # View details about a supporter.
    print "=== View details about a supporter. ==="
    supporter = select_supporter()
    view_supporter(supporter)
  elif command == 'a':
    # Add a supporter.
    print "=== Add a supporter. ==="
    create_supporter()
  elif command == 'm':
    # Modify a supporter.
    print "=== Modify a supporter. ==="
    supporter = select_supporter()
    set_supporter(supporter)
  elif command == 'd':
    # Delete a supporter.
    print "=== Delete a supporter. ==="
    supporter = select_supporter()
    delete_supporter(supporter)
  # elif command == 'b':
  #   Do nothing.
  return

def select_supporter():
  print "Select a supporter:"
  cursor.execute("""
  SELECT * FROM supporter;
  """)
  for supporter in cursor.fetchall():
    # Supporter[0] is the supporter's ID.
    print "   %d - %s" % (supporter[0], supporter[3])
  command = raw_input("Select your supporter: ")
  return command

def create_supporter():
  print "Create a supporter..."
  the_supporter = {
    'ID': raw_input("Enter the supporter ID: "),
    'Name': raw_input("Enter the supporter Name: "),
    'Email': raw_input("Enter the supporter Email: "),
    'Phone': raw_input("Enter the supporter Phone Number: "),
    'Title': raw_input("Enter the supporter Title (Optional): ")
  }
  cursor.execute("""
  INSERT INTO supporter VALUES (%(ID)s, %(Phone)s, %(Email)s, %(Name)s, %(Title)s);
  """, the_supporter)
  print "=== Inserted supporter. ==="
  print "Collecting any additional information..."
  if raw_input("Does this supporter have a contact they work with? (y/N): ") == 'y':
    works_with = raw_input("Supporter works with (Supporter's ID): ")
    if works_with != '':
      cursor.execute("""
      INSERT INTO workswith VALUES (%s, %s);
      """, (the_supporter["ID"], works_with,))
      print "=== Inserted workswith. ==="
  dbconn.commit()
  print "=== Done creating a supporter. ==="

def view_supporter(supporterID):
  cursor.execute("""
  SELECT * FROM supporter WHERE ID = %s
  """, (supporterID,))
  supporter = cursor.fetchall()[0]
  print "   ID:    %s" % supporter[0]
  print "   Name:  %s" % supporter[3]
  print "   Email: %s" % supporter[2]
  print "   Phone: %s" % supporter[1]
  if supporter[4] != None:
    print "   Title: %s" % supporter[4]

def set_supporter(supporterID):
  cursor.execute("""
  SELECT * FROM supporter WHERE ID = %s
  """, (supporterID,))
  supporter = cursor.fetchall()[0]
  supporter_input = {
    'ID':    raw_input("   ID (%s):    " % supporter[0]) or supporter[0],
    'Name':  raw_input("   Name (%s):  " % supporter[3]) or supporter[3],
    'Email': raw_input("   Email (%s): " % supporter[2]) or supporter[2],
    'Phone': raw_input("   Phone (%s): " % supporter[1]) or supporter[1]
  }
  if supporter[4] == None or supporter[4] == '':
    supporter_input['Title'] = raw_input("   Title: ") or None
  else:
    supporter_input['Title'] = raw_input("   Title (%s): " % supporter[4]) or supporter[4]
  cursor.execute("""
  INSERT INTO supporter VALUES (%(ID)s, %(Phone)s, %(Email)s, %(Name)s, %(Title)s);
  """, supporter_input)
  dbconn.commit()
  print "=== Done modifying the supporter. ==="

def delete_supporter(supporterID):
  cursor.execute("""
  SELECT * FROM supporter WHERE ID = %s
  """, (supporterID,))
  supporter = cursor.fetchall()[0]
  print "You're proposing we delete %s from the system? Lets look at their overview:" % supporter[3]
  print "   ID:    %s" % supporter[0]
  print "   Name:  %s" % supporter[3]
  print "   Email: %s" % supporter[2]
  print "   Phone: %s" % supporter[1]
  if supporter[4] != None:
    print "   Title: %s" % supporter[4]
  if raw_input("Are you sure you want to delete them? (y/N): ") == 'y':
    cursor.execute("""
    DELETE FROM supporter WHERE ID = (%s)
    """, (supporterID,))
    dbconn.commit()
    print "=== Deleted %s from the database. ===" % supporter[3]
  else:
    print "=== Aborted deletion of %s. ===" % supporter[3]

############################################
# Campaigns                                #
############################################

def campaign_management():
  # TODO: Add events!
  print (
    "Your options are:\n"
    "   v - View details about a campaign.\n"
    "   a - Add a campaign.\n"
    "   m - Modify a campaign.\n"
    "   d - Delete a campaign.\n"
    "   b - Go back home."
  )
  command = raw_input("Select Functionality: ")
  # Handle input.
  if command == 'v':
    # View details about a supporter.
    print "=== View details about a campaign. ==="
    campaign = select_campaign()
    view_campaign(campaign)
  elif command == 'a':
    # Add a supporter.
    print "=== Add a campaign. ==="
    create_campaign()
  elif command == 'm':
    # Modify a supporter.
    print "=== Modify a campaign. ==="
    campaign = select_campaign()
    set_campaign(campaign)
  elif command == 'd':
    # Delete a supporter.
    print "=== Delete a campaign. ==="
    campaign = select_campaign()
    delete_campaign(campaign)
  # elif command == 'b':
  #   Do nothing.
  return

############################################
# Event                                    #
############################################

def event_management():
  # TODO: Add events!
  print (
    "Your options are:\n"
    "   v - View details about a event.\n"
    "   a - Add a event.\n"
    "   m - Modify a event.\n"
    "   d - Delete a event.\n"
    "   b - Go back home."
  )
  command = raw_input("Select Functionality: ")
  # Handle input.
  if command == 'v':
    # View details about a supporter.
    print "=== View details about a event. ==="
    event = select_event()
    view_event(event)
  elif command == 'a':
    # Add a supporter.
    print "=== Add a event. ==="
    create_event()
  elif command == 'm':
    # Modify a supporter.
    print "=== Modify a event. ==="
    event = select_event()
    set_event(event)
  elif command == 'd':
    # Delete a supporter.
    print "=== Delete a event. ==="
    event = select_event()
    delete_event(event)
  # elif command == 'b':
  #   Do nothing.
  return

############################################
# Account                                  #
############################################

def account_management():
  print (
    "Your options are:\n"
    "   v - View details about a account.\n"
    "   a - Add an account.\n"
    "   m - Modify a account.\n"
    "   d - Delete a account.\n"
    "   b - Go back home."
  )
  command = raw_input("Select Functionality: ")
  # Handle input.
  if command == 'v':
    # View details about a supporter.
    print "=== View details about a account. ==="
    account = select_campaign()
    view_account(account)
  elif command == 'a':
    # Add a supporter.
    print "=== Add a account. ==="
    create_campaign()
  elif command == 'm':
    # Modify a supporter.
    print "=== Modify a account. ==="
    account = select_account()
    set_account(account)
  elif command == 'd':
    # Delete a supporter.
    print "=== Delete a account. ==="
    account = select_account()
    delete_account(account)
  # elif command == 'b':
  #   Do nothing.
  return

############################################
# Main                                     #
############################################

# Main
def main(argv=None):
  """
  Do what must be done!
  """
  #
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
      "   b - Browse Prebuilt Queries.\n"
      "   s - Supporter Management.\n"
      "   c - Campaign Management.\n"
      "   e - Event Management.\n"
      "   a - Account Management.\n"
      "   z - Make a custom SQL statement. (Advanced)\n"
      "   q - Quits the program."
    )
    command = raw_input("Select Functionality: ")
    # Handle input.
    if command == 'b':
      # Browse Queries.
      print "=== Browse Prebuilt Queries. =="
      query = select_queries();
      if query is not None:
        result = select_all(query)
        print_as_table(result['schema'], result['data'])
      else:
        continue
    elif command == 's':
      # Supporter Management.
      print "=== Supporter Management. ==="
      supporter_management();
    elif command == 'c':
      # Campaign Management
      print "=== Campaign Management. ==="
      campaign_management();
    elif command == 'e':
      print "=== Event Management ==="
      event_management();
    elif command == 'a':
      # Account Management.
      print "=== Account Management. ==="
      account_management();
    elif command == 'z':
      # Make a custom SQL statement. (Advanced)
      print "=== Make a custom SQL statement. (Advanced) ==="
      custom_statement();
    elif command == 'q':
      # Quit
      print "=== Quits the program. ==="
      return 0;
    print "=== Returning to Home.==="

if __name__ == "__main__":
  sys.exit(main())
