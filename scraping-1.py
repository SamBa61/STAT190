# need to run pip install _ in terminal
import requests
from bs4 import BeautifulSoup
import csv

# selected 2024
url = "https://transmission.bpa.gov/Business/Operations/Outages/OutagesCY2024.htm"
page = requests.get(url)
data = page.content

parsed_data = BeautifulSoup(data, "html.parser")

# Open CSV file in write mode
with open('OneDrive/Documents/STAT190/outages_2024.csv', mode='w', newline='') as csv_file:
    writer = csv.writer(csv_file)

    # Write headers
    writer.writerow(['OutDatetime', 'InDatetime', 'Name', 'Voltage', 'DurationMin', 'OutageType', 'Cause', 'ResponsibleSystem', 'intprt', 'District', 'ID'])  # Replace with actual column names

    table = parsed_data.find('table')
    rows = table.find_all('tr')
    for row in rows:
        # Extract data from each row and write it to the CSV file
        cols = row.find_all('td')
        cols = [col.text.strip() for col in cols]
        writer.writerow(cols)
