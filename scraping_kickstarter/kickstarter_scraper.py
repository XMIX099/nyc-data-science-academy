# coding: utf-8

from selenium import webdriver
import pandas as pd
import time 
from datetime import datetime
from collections import OrderedDict
import re

browser = webdriver.Firefox()
browser.get('https://www.kickstarter.com/discover?ref=nav')
categories = browser.find_elements_by_class_name('category-container')

category_links = []
for category_link in categories:
    #Each item in the list is a tuple of the category's name and its link.
    category_links.append((str(category_link.find_element_by_class_name('h3').text),
                         category_link.find_element_by_class_name('bg-white').get_attribute('href')))


scraped_data = []
now = datetime.now()
counter = 1

for category in category_links:
    browser.get(category[1])
    browser.find_element_by_class_name('sentence-open').click()
    time.sleep(2)
    browser.find_element_by_id('category_filter').click()
    time.sleep(2)
    
    for i in range(27):
        try:
            time.sleep(2)
            browser.find_element_by_id('category_'+str(i)).click()
            time.sleep(2)            
        except:
            pass
    
	#while True:
	#	try:
	#		browser.find_element_by_class_name('load_more').click()
	#	except:
	#		break			
    
    projects = []
    for project_link in browser.find_elements_by_class_name('project-title'):
        projects.append(project_link.find_element_by_tag_name('a').get_attribute('href'))
    
    for project in projects:
        time.sleep(2)
        print(str(counter)+': '+project+'\nStatus: Started.')
        project_dict = OrderedDict()
        project_dict['Category'] = category[0]
        browser.get(project)
        project_dict['Name'] = browser.find_elements_by_class_name('green-dark')[0].text

        try:
            try:
                project_dict['Num_Of_Backers'] = int(browser.find_element_by_id('backers_count').text.replace(',',''))
            except:
                project_dict['Num_Of_Backers'] = int(browser.find_element_by_class_name('num h1 bold').get_attribute('data-backers-count'))            
        except:
            project_dict['Num_Of_Backers'] = int(browser.find_element_by_class_name('NS_projects__spotlight_stats').find_element_by_tag_name('b').text.replace(',','').split(' ')[0])

        try:
            project_dict['Currency'] = str(browser.find_element_by_id('pledged').text[0])
        except:
            project_dict['Currency'] = str(re.sub(',','',browser.find_element_by_class_name('money').text[0]))

        try:    
            project_dict['Amount-Pledged'] = float(browser.find_element_by_id('pledged').text[1:].replace(',',''))
        except:
            project_dict['Amount-Pledged'] = float(browser.find_elements_by_class_name('mb1')[-1].text[1:].replace(',',''))

        try:
            project_dict['Goal'] = float(browser.find_elements_by_class_name('money')[1].text[1:].replace(',',''))
        except:
            project_dict['Goal'] = float(browser.find_elements_by_class_name('h5')[8].find_element_by_class_name('money').text[1:].replace(',',''))

        project_dict['Funded'] = int(project_dict['Amount-Pledged'] >= project_dict['Goal'])

        try:
            project_dict['Time_Remaining'] = (browser.find_element_by_class_name('ksr_page_timer').find_element_by_class_name('num').text,
                                          browser.find_element_by_class_name('ksr_page_timer').find_element_by_class_name('text').text.split(' ')[0]) 
        except:
            project_dict['Time_Remaining'] = 0

        project_dict['About'] = '\n'.join([a.text for a in browser.find_elements_by_tag_name('p')[5:-3]])

        project_dict['Num_Of_Comments'] = re.search('\d+',browser.find_elements_by_class_name('js-load-project-content')[3].text).group()
        project_dict['Num_Of_Updates'] = re.search('\d+',browser.find_elements_by_class_name('js-load-project-content')[2].text).group()

        print('Status: Done.')
        counter+=1
        scraped_data.append(project_dict)
    
later = datetime.now()
diff = later - now

print('The scraping took '+str(round(diff.seconds/60.0,2))+' minutes, and scraped '+str(len(scraped_data))+' projects.')

df = pd.DataFrame(scraped_data)
df.to_csv('kickstarter-data.csv')


