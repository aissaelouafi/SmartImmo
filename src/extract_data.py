# -*- coding: utf-8 -*-
import re,sys,requests,json
from pprint import pprint
import pysolr, random
import unidecode

"""
    This script extract data from avito API and push them into SOLR collection
    @input : category id, city id 
"""
def main():
    category = 1000
    solr = pysolr.Solr('http://localhost:8983/solr/smartimmo',timeout=10)
    url = "https://www.avito.ma/lij?fullad=1&cg="+str(category)+"&st=s&o=1"
    r = requests.get(url)
    request_content = r.text
    json_content = json.loads(request_content)
    print("Total ads in category "+str(category)+" : "+str(json_content["total_ads"]))
    extracted_ads = int(json_content["extracted_ads"])

    total_pages = json_content["total_ads"]/extracted_ads

    for page in xrange(5230,total_pages):

        print("Extract page : "+str(page)+" from "+str(json_content["total_ads"]/extracted_ads)+"  "+str(round(extracted_ads/json_content["total_ads"]*100,2))+"%")


        url = "https://www.avito.ma/lij?fullad=1&cg=" + str(category) + "&st=s&o="+str(page)
        r = requests.get(url)
        request_content = r.text
        json_content = json.loads(request_content)

        list_ads = json_content["list_ads"]

        for i in xrange(extracted_ads):
            data = []

            for key,value in list_ads[i].items():
                if type(value) == unicode:
                    data.append((unidecode.unidecode(key),value))

            for key,value in list_ads[i]["full_ad_data"].items():
                if type(value) == unicode:
                    data.append((unidecode.unidecode(key),value))


            for detail in list_ads[i]["full_ad_data"]["ad_details"]:
                if len(detail) != 0:
                    #if detail['label'] == '':
                    #   detail['label'] = "label_" + str(random.randint(1, 5000))
                    data.append((unidecode.unidecode(detail['label']),detail['value']))
            data = dict(data)
            data_list = []
            data_list.append(data)
            solr.add(data_list)

if __name__ == "__main__":
    main()