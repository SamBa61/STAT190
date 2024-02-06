# need to run pip install _ in terminal for all packages below
import requests
import csv
from bs4 import BeautifulSoup as bs

def web_scrape(url, filepath, headers_list, table_separator, rows_separator, cols_separator):
  # selected 2024 - writes only first table of link
  # also, can change url year with Python formatting 
  url = url
  
  # create for loop here, rows will need to be appended to created dataset
  # 26 years on website
  
  for i in range(1, 26):
    
  
  page = requests.get(url)
  data = page.content
  
  parsed_data = bs(data, "html.parser")
  
  # convert into csv file - Open CSV file in write mode
  with open(filepath, mode='w', newline='') as csv_file:
      writer = csv.writer(csv_file)
  
      # Write headers
      writer.writerow(headers_list)  # Replace with actual column names
  
      table = parsed_data.find(table_separator)
      rows = table.find_all(rows_separator)
      for row in rows:
          # Extract data from each row and write it to the CSV file
          cols = row.find_all(cols_separator)
          cols = [col.text.strip() for col in cols]
          writer.writerow(cols)



web_scrape("https://transmission.bpa.gov/Business/Operations/Outages/OutagesCY2024.htm", 
'/Users/sambasala/Desktop/STAT 190/DataCapstone/outages_2024.csv', 
['OutDatetime', 'InDatetime', 'Name', 'Voltage', 'DurationMin', 'OutageType', 'Cause', 'ResponsibleSystem', 'intprt', 'District', 'ID'],
'table', 'tr', 'td')
