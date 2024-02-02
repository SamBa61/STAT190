# need to run pip install _ in terminal
import requests
from bs4 import BeautifulSoup

# selected 2024
url = "https://transmission.bpa.gov/Business/Operations/Outages/OutagesCY2024.htm"
page = requests.get(url)
data = page.content

parsed_data = BeautifulSoup(data, "html.parser")

print(parsed_data.prettify())