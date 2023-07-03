#!/usr/bin/env python
# -*- coding: utf-8 -*-


import json
import requests


def get_json_data(C,idxn):
    url = 'https://global.bing.com/HPImageArchive.aspx?format=js&n=1&pid=hp&FORM=BEHPTB&uhd=1&uhdwidth=3840&uhdheight=2160&mkt=' + C + '&idx=' + idxn
    headers = {
        'User-Agent':"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36"
    }

    respond = requests.get(url,headers=headers)
    jsoned = json.loads(respond.content.decode("utf-8"))
    finalu = jsoned['images'][0]['url']
    urlbase = jsoned['images'][0]['urlbase']
    resolutions = 'UHD'

    return {
      'sta_date': jsoned['images'][0]['startdate'],
      'end_date': jsoned['images'][0]['enddate'],
      'title': jsoned['images'][0]['title'],
      'copyright': jsoned['images'][0]['copyright'],
      'imagebase': "https://www.bing.com" + urlbase + '_' + resolutions + '.jpg',
      'image_url': "https://www.bing.com" + finalu
    }


if __name__ == '__main__':
    res = get_json_data('')
    print(json.dumps(res, ensure_ascii=False, indent=2))



"""
resolutions:

[
UHD
1920x1200
1920x1080
1080x1920
1366x768
1280x768
1024x768
800x600
800x480
768x1280
720x1280
640x480
480x800
400x240
320x240
240x320
]

"""
