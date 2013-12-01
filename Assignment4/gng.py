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
import datetime # Dates

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
  """
  Prompts the user to go deeper into supporter management.
  """
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
  """
  Selects a supporter by ID
  """
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
  """
  Creates a supporter.
  """
  print "Create a supporter..."
  the_supporter = {
    'ID': raw_input("Enter the supporter ID: "),
    'Name': raw_input("Enter the supporter Name: "),
    'Email': raw_input("Enter the supporter Email: "),
    'Phone': raw_input("Enter the supporter Phone Number: "),
    'Title': raw_input("Enter the supporter Title (Optional): "),
    'Annotation': raw_input("Annotation: ")
  }
  cursor.execute("""
  INSERT INTO supporter VALUES (%(ID)s, %(Phone)s, %(Email)s, %(Name)s, %(Title)s, %(Annotation)s);
  """, the_supporter)
  print "=== Inserted supporter. ==="
  print "Collecting any additional information..."
  # Workswith
  if raw_input("Does this supporter have a contact they work with? (y/N): ") == 'y':
    works_with = select_supporter()
    if works_with != '':
      cursor.execute("""
      INSERT INTO workswith VALUES (%s, %s), (%s, %s);
      """, (works_with, the_supporter["ID"], the_supporter["ID"], works_with,))
      print "=== Inserted workswith. ==="
  # Employee?
  if raw_input("Is this supporter an employee? (y/N): ") == 'y':
    the_salary = int(raw_input("  What is their Salary per year? (1000): ") or 1000)
    cursor.execute("""
    INSERT INTO employee VALUES (%s, %s);
    """, (the_supporter['ID'], the_salary,))
  #
  dbconn.commit()
  print "=== Done creating a supporter. ==="

def view_supporter(supporterID):
  """
  Views a supporter.
  """
  cursor.execute("""
  SELECT * FROM supporter WHERE ID = %s
  """, (supporterID,))
  supporter = cursor.fetchall()[0]
  print "ID:    %s" % supporter[0]
  print "Name:  %s" % supporter[3]
  print "Email: %s" % supporter[2]
  print "Phone: %s" % supporter[1]
  if supporter[4] != None:
    print "Title: %s" % supporter[4]
  if supporter[5] != None:
    print "Annotation: %s" % supporter[5]
  # Salary?
  cursor.execute("""
  SELECT * FROM employee WHERE ID = %s
  """, (supporter[0],))
  for item in cursor.fetchall():
    print "Salary: %s" % item[1]
  # WorksWith
  print "Working relationships:"
  cursor.execute("""
  SELECT * FROM workswith
  INNER JOIN supporter ON (WorksWith.Supporter2 = Supporter.ID)
  WHERE WorksWith.Supporter1 = (%s);
  """, (supporter[0],))
  for item in cursor.fetchall():
    print "  %s works with %s" % (supporter[3], item[5])

def set_supporter(supporterID):
  """
  Modifies a supporter and saves it.
  """
  cursor.execute("""
  SELECT * FROM supporter WHERE ID = %s
  """, (supporterID,))
  supporter = cursor.fetchall()[0]
  supporter_input = {
    'ID':    raw_input("ID (%s):    " % supporter[0]) or supporter[0],
    'Name':  raw_input("Name (%s):  " % supporter[3]) or supporter[3],
    'Email': raw_input("Email (%s): " % supporter[2]) or supporter[2],
    'Phone': raw_input("Phone (%s): " % supporter[1]) or supporter[1]
  }
  # Title
  if supporter[4] == None or supporter[4] == '':
    supporter_input['Title'] = raw_input("Title: ") or None
  else:
    supporter_input['Title'] = raw_input("Title (%s): " % supporter[4]) or supporter[4]
  # Annotation.
  if supporter[5] == None or supporter[5] == '':
    supporter_input['Annotation'] = raw_input("Annotation: ") or None
  else:
    supporter_input['Annotation'] = raw_input("Annotation (%s): " % supporter[5]) or supporter[5]
  #
  cursor.execute("""
  UPDATE supporter SET ID = %(ID)s, Phone = %(Phone)s, Email = %(Email)s, Name = %(Name)s, Title = %(Title)s, Annotation = %(Annotation)s WHERE
  ID = %(ID)s;
  """, supporter_input)
  # Employee
  cursor.execute("""
  SELECT * FROM employee WHERE ID = %s;
  """, (supporter[0],))
  result = cursor.fetchall()
  if len(result) > 0:
    new_salary = int(raw_input("Salary (%s): " % result[0]) or result[0])
    cursor.execute("""
    UPDATE employee SET salary = %s WHERE ID = %s;
    """, (new_salary, supporter[0],))
  elif raw_input("Make this person an employee? (y/N)") == 'y':
    new_salary = int(raw_input("Salary (1000): ") or 1000)
    cursor.execute("""
    INSERT INTO employee VALUES (%s, %s);
    """, (supporter[0], new_salary,))
  # WorksWith
  cursor.execute("""
    SELECT * FROM workswith
    INNER JOIN supporter ON (WorksWith.Supporter2 = Supporter.ID)
    WHERE WorksWith.Supporter1 = (%s);
    """, (supporter[0],))
  for item in cursor.fetchall():
    print item
    choice = raw_input("%s works with %s, delete (d)? Or leave it (Nothing): " % (supporter[3], item[5])
)
    if choice == 'd':
      cursor.execute("""
      DELETE FROM workswith WHERE supporter1 = (%s) AND supporter2 = (%s)
      """, (supporter[0], item[1],))
  while True:
    if raw_input("Add new relationship? (y/N): ") == 'y':
      cursor.execute("""
      INSERT INTO workswith VALUES (%s, %s);
      """, (supporter[0], select_supporter(),))
    else:
      break
  #
  dbconn.commit()
  print "=== Done modifying the supporter. ==="

def delete_supporter(supporterID):
  """
  Deletes a supporter
  """
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
  if supporter[5] != None:
    print "   Annotation: %s" % supporter[5]
  if raw_input("Are you sure you want to delete them? (y/N): ") == 'y':
    cursor.execute("""
    DELETE FROM workswith WHERE supporter1 = (%s)
    """, (supporter[0],))
    cursor.execute("""
    DELETE FROM supporter WHERE ID = (%s)
    """, (supporterID,))
    dbconn.commit()
    print "=== Deleted %s from the database. ===" % supporter[3]
  else:
    print "=== Aborted deletion of %s. ===" % supporter[3]

############################################
# Campaigns                               #
############################################

def campaign_management():
  """
  Prompts the user to go deeper into campaign management.
  """
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
    # View details about a campaign.
    print "=== View details about a campaign. ==="
    campaign = select_campaign()
    view_campaign(campaign)
  elif command == 'a':
    # Add a campaign.
    print "=== Add a campaign. ==="
    create_campaign()
  elif command == 'm':
    # Modify a campaign.
    print "=== Modify a campaign. ==="
    campaign = select_campaign()
    set_campaign(campaign)
  elif command == 'd':
    # Delete a campaign.
    print "=== Delete a campaign. ==="
    campaign = select_campaign()
    delete_campaign(campaign)
  # elif command == 'b':
  #   Do nothing.
  return

def select_campaign():
  """
  Selects a campaign by ID
  """
  print "Select a campaign:"
  cursor.execute("""
  SELECT * FROM campaign;
  """)
  choices = []
  for i, campaign in enumerate(cursor.fetchall()):
    choices.append(campaign[0])
    # campaign[0] is the campaign's ID.
    print "   %d - %s: %s" % (i, campaign[0], campaign[1])
  command = int(raw_input("Select your campaign: "))
  return choices[command]

def create_campaign():
  """
  Creates a campaign.
  """
  print "Create a campaign..."
  the_campaign = {
    'Title': raw_input("Enter the campaign title: "),
    'Slogan': raw_input("Enter the campaign slogan: "),
    'PhaseNumber': 1,
    'Annotation': raw_input("Annotation: ")
  }
  cursor.execute("""
  INSERT INTO campaign VALUES (%(Title)s, %(Slogan)s, %(PhaseNumber)s, %(Annotation)s);
  """, the_campaign)
  print "=== Inserted campaign. ==="
  print "Collecting any additional information..."
  phases = []
  for i in range(int(raw_input("How many phases is this campaign? (1): ")) or 0):
    print "Info for Phase %d:" % (i + 1)
    phases.append({
      'PhaseNumber':    i + 1,
      'CampaignTitle':  the_campaign['Title'],
      'Goal':           raw_input("  What is this phases goal?: "),
    })
    print "Start time: "
    phases[i]['StartTime'] = datetime.date(
      int(raw_input("  Year: ")),
      int(raw_input("  Month: ")),
      int(raw_input("  Day: "))
    )
    print "End time: "
    phases[i]['EndTime'] = datetime.date(
      int(raw_input("  Year: ")),
      int(raw_input("  Month: ")),
      int(raw_input("  Day: "))
    )
    cursor.execute("""
    INSERT INTO phase VALUES (%(PhaseNumber)s, %(CampaignTitle)s, %(Goal)s, %(StartTime)s, %(EndTime)s);
    """, phases[i])
  dbconn.commit()
  print "=== Done creating a campaign. ==="

def view_campaign(campaignID):
  """
  Views a campaign.
  """
  cursor.execute("""
  SELECT * FROM campaign WHERE Title = %s;
  """, (campaignID,))
  campaign = cursor.fetchall()[0]
  print "   Title:   %s" % campaign[0]
  print "   Slogan:  %s" % campaign[1]
  print "   Current Phase:   %s" % campaign[2]
  if campaign[3]:
    print "    Annotation: %s" % campaign[3]
  # Phases
  cursor.execute("""
  SELECT * FROM phase WHERE CampaignTitle = %s;
  """, (campaignID,))
  for phase in cursor.fetchall():
    print "   PhaseNumber: %d" % phase[0]
    print "     Goal:        %s" % phase[2]
    print "     StartTime:   %s" % phase[3]
    print "     EndTime:     %s" % phase[4]

def set_campaign(campaignID):
  """
  Modifies a campaign and saves it.
  """
  # Need to disable constraints.
  cursor.execute("""
  SET CONSTRAINTS ALL DEFERRED 
  """)
  #
  cursor.execute("""
  SELECT * FROM campaign WHERE Title = %s
  """, (campaignID,))
  campaign = cursor.fetchall()[0]
  campaign_input = {
    'OldTitle': campaign[0],
    'Title':    raw_input("  Title  (%s): " % campaign[0]) or campaign[0],
    'Slogan':   raw_input("  Slogan (%s): " % campaign[1]) or campaign[1],
    'CurrentPhase': int(raw_input("  CurrentPhase (%d):  " % campaign[2]) or campaign[2]),
    'Annotation': raw_input("  Annotation (%s): " % campaign[3]) or campaign[3]
  }
  # Modification
  cursor.execute("""
  UPDATE campaign SET Title = %(Title)s, Slogan = %(Slogan)s, CurrentPhase = %(CurrentPhase)s, Annotation = %(Annotation)s WHERE
  Title = %(OldTitle)s;
  """, campaign_input)
  # Phases
  print "Modifying Phases: "
  cursor.execute("""
  SELECT * FROM phase WHERE CampaignTitle = %(Title)s;
  """, campaign_input)
  for phase in cursor.fetchall():
    print "Phase %d" % phase[0]
    new_phase = {
        'PhaseNumber': phase[0],
        'CampaignTitle': campaign_input['Title'],
    }
    new_phase['Goal']      = raw_input("   Goal (%s): " % phase[2])
    print " Start time: "
    new_phase['StartTime'] = datetime.date(
      int(raw_input("  Year (%s): " % phase[3].year) or phase[3].year),
      int(raw_input("  Month (%s): " % phase[3].month) or phase[3].month),
      int(raw_input("  Day (%s): " % phase[3].day) or phase[3].day)
    )
    print " End time: "
    new_phase['EndTime'] = datetime.date(
      int(raw_input("  Year (%s): " % phase[4].year) or phase[4].year),
      int(raw_input("  Month (%s): " % phase[4].month) or phase[4].month),
      int(raw_input("  Day (%s): " % phase[4].day) or phase[4].day)
    )
    cursor.execute("""
    UPDATE phase SET CampaignTitle = %(CampaignTitle)s, Goal = %(Goal)s, StartTimestamp = %(StartTime)s, EndTimeStamp = %(EndTime)s WHERE
    PhaseNumber = %(PhaseNumber)s AND CampaignTitle = %(CampaignTitle)s;
    """, new_phase)
  dbconn.commit()
  print "=== Done modifying the campaign. ==="

def delete_campaign(campaignID):
  """
  Deletes a campaign
  """
  cursor.execute("""
  SELECT * FROM campaign WHERE Title = %s;
  """, (campaignID,))
  campaign = cursor.fetchall()[0]
  print "You're proposing we delete the campaign '%s' from the system? Lets look at it's overview:" % campaign[0]
  print "   Title:   %s" % campaign[0]
  print "   Slogan:  %s" % campaign[1]
  print "   Current Phase:   %s" % campaign[2]
  if campaign[3]:
      print "   Annotation:   %s" % campaign[3]
  # Print Phases
  cursor.execute("""
  SELECT * FROM phase WHERE campaignTitle = %s;
  """, (campaign[0],))
  for phase in cursor.fetchall():
    print "   PhaseNumber: %d" % phase[0]
    print "     Goal:        %s" % phase[2]
    print "     StartTime:   %s" % phase[3]
    print "     EndTime:     %s" % phase[4]
  if raw_input("Are you sure you want to delete them? (y/N): ") == 'y':
    # Also get the phases.
    cursor.execute("""
    DELETE FROM phase WHERE CampaignTitle = (%s);
    """, (campaignID,))
    cursor.execute("""
    DELETE FROM campaign WHERE Title = (%s);
    """, (campaignID,))
    dbconn.commit()
    print "=== Deleted %s from the database. ===" % campaign[0]
  else:
    print "=== Aborted deletion of %s. ===" % campaign[0]

############################################
# Event                                    #
############################################

def event_management():
  """
  Prompts the user to go deeper into event management.
  """
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
    # View details about a event.
    print "=== View details about a event. ==="
    event = select_event()
    view_event(event)
  elif command == 'a':
    # Add a event.
    print "=== Add a event. ==="
    create_event()
  elif command == 'm':
    # Modify a event.
    print "=== Modify a event. ==="
    event = select_event()
    set_event(event)
  elif command == 'd':
    # Delete a event.
    print "=== Delete a event. ==="
    event = select_event()
    delete_event(event)
  # elif command == 'b':
  #   Do nothing.
  return

def select_event():
  """
  Selects a event by ID
  """
  print "Select a event:"
  cursor.execute("""
  SELECT * FROM event;
  """)
  for event in cursor.fetchall():
    # event[0] is the event's ID.
    print "   %d - %s (%s)" % (event[0], event[1], event[2])
  command = raw_input("Select your event: ")
  return command

def create_event():
  """
  Creates a event.
  """
  print "Create a event..."
  the_event = {
    'ID': raw_input("Enter the event ID: "),
    'Name': raw_input("Enter the event Name: "),
    'Location': raw_input("Enter the event Location: "),
    'Annotation': raw_input("Annotation: ")
  }
  # Datetimes
  print "Start Time:"
  the_event['StartTime'] = datetime.datetime(
    int(raw_input("  Year: ")),
    int(raw_input("  Month: ")),
    int(raw_input("  Day: ")),
    int(raw_input("  Hour: ")),
    int(raw_input("  Minute: ")),
  )
  print "End Time:"
  the_event['EndTime'] = datetime.datetime(
    int(raw_input("  Year: ")),
    int(raw_input("  Month: ")),
    int(raw_input("  Day: ")),
    int(raw_input("  Hour: ")),
    int(raw_input("  Minute: ")),
  )
  
  cursor.execute("""
  INSERT INTO event VALUES (%(ID)s, %(Name)s, %(Location)s, %(StartTime)s, %(EndTime)s, %(Annotation)s);
  """, the_event)
  print "=== Inserted event. ==="
  if raw_input("Is this event associated with a campaign/phase? (y/N)? ") == 'y':
    partof = {
      'EventID': the_event['ID'],
      'Title': select_campaign(),
      'PhaseNumber': raw_input("Which phase of this campaign? (1)") or 1
    }
  dbconn.commit()
  print "=== Done creating a event. ==="

def view_event(eventID):
  """
  Views a event.
  """
  cursor.execute("""
  SELECT * FROM event WHERE ID = %s
  """, (eventID,))
  event = cursor.fetchall()[0]
  print "ID:        %s" % event[0]
  print "Name:      %s" % event[1]
  print "Location:  %s" % event[2]
  print "StartTime: %s" % event[3]
  print "EndTime:   %s" % event[4]
  if event[5]:
    print "Annotation: %s" % event[5] 
  cursor.execute("""
  SELECT * FROM PartOf WHERE EventID = %s;
  """, (event[0],))
  parts = cursor.fetchall()
  if len(parts) >= 1:
    for part in parts:
      print "Part of event %s, phase %d" % (part[1], part[2])

def set_event(eventID):
  """
  Modifies a event and saves it.
  """
  cursor.execute("""
  SELECT * FROM event WHERE ID = %s
  """, (eventID,))
  event = cursor.fetchall()[0]
  event_input = {
    'ID':    raw_input("ID (%s):    " % event[0]) or event[0],
    'Name':  raw_input("Name (%s):  " % event[1]) or event[1],
    'Location': raw_input("Location (%s): " % event[2]) or event[2],
    'Annotation': raw_input("Annotation (%s): " % event[5]) or event[5]
  }
  # Datetimes
  print " Start time: "
  event_input['StartTime'] = datetime.datetime(
    int(raw_input("  Year (%s): " % event[3].year) or event[3].year),
    int(raw_input("  Month (%s): " % event[3].month) or event[3].month),
    int(raw_input("  Day (%s): " % event[3].day) or event[3].day),
    int(raw_input("  Hour (%s): " % event[3].hour) or event[3].hour),
    int(raw_input("  Minute (%s): " % event[3].minute) or event[3].minute)
  )
  print " End time: "
  event_input['EndTime'] = datetime.datetime(
    int(raw_input("  Year (%s): " % event[4].year) or event[4].year),
    int(raw_input("  Month (%s): " % event[4].month) or event[4].month),
    int(raw_input("  Day (%s): " % event[4].day) or event[4].day),
    int(raw_input("  Hour (%s): " % event[4].hour) or event[4].hour),
    int(raw_input("  Minute (%s): " % event[4].minute) or event[4].minute)
  )
  #
  cursor.execute("""
  UPDATE event SET ID = %(ID)s, Name = %(Name)s, Location = %(Location)s, StartTimeStamp = %(StartTime)s, EndTimeStamp = %(EndTime)s, Annotation = %(Annotation)s WHERE
  ID = %(ID)s;
  """, event_input)
  # Check partof
  cursor.execute("""
  SELECT * FROM partof WHERE eventID = %s
  """, (eventID,))
  parts = cursor.fetchall()
  if parts:
    for part in parts:
      choice = raw_input("This event is currently part of %s, phase %d... Modify it (m)? or Delete it (d)? or do nothing (Enter nothing): " % (part[1], part[2]))
      if choice == 'd':
        cursor.execute("""
        DELETE FROM partof WHERE eventID = (%s) AND Title = (%s) AND phaseNumber = (%s);
        """, (part[0], part[1], part[2],))
      elif choice == 'm':
        new_campaign = select_campaign()
        new_phase = raw_input("New Phase Number: ")
        cursor.execute("""
        UPDATE partof SET title = (%s), PhaseNumber = (%s) WHERE
        eventID = %s AND title = %s AND phaseNumber = %s;
        """, (new_campaign, new_phase, part[0], part[1], part[2],))
  elif raw_input("Add this event to a campaign? (y/N): ") == 'y':
    cursor.execute("""
    INSERT INTO partof VALUES (%s, %s, %s);
    """, (event[0], select_campaign(), int(raw_input("Which phase?: "))))
  dbconn.commit()
  print "=== Done modifying the event. ==="

def delete_event(eventID):
  """
  Deletes a event
  """
  cursor.execute("""
  SELECT * FROM event WHERE ID = %s
  """, (eventID,))
  event = cursor.fetchall()[0]
  print "You're proposing we delete %s from the system? Lets look at it's overview:" % event[1]
  print "ID:        %s" % event[0]
  print "Name:      %s" % event[1]
  print "Location:  %s" % event[2]
  print "StartTime: %s" % event[3]
  print "EndTime:   %s" % event[4]
  if event[5]:
    print "Annotation: %s" % event[5]
  cursor.execute("""
  SELECT * FROM partof WHERE eventID = (%s);
  """, (event[0],))
  for item in cursor.fetchall():
    print "This even is part of %s, phase %d" % (item[1], item[2])
  if raw_input("Are you sure you want to delete it? (y/N): ") == 'y':
    cursor.execute("""
    DELETE FROM partof WHERE EventID = (%s);
    """, (event[0],))
    cursor.execute("""
    DELETE FROM event WHERE ID = (%s)
    """, (eventID,))
    dbconn.commit()
    print "=== Deleted %s from the database. ===" % event[1]
  else:
    print "=== Aborted deletion of %s. ===" % event[1]

############################################
# Account                                  #
############################################

def account_management():
  print (
    "Your options are:\n"
    "   v - View details about a account.\n"
    "   a - Add an account.\n"
    "   m - Modify a account.\n"
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
