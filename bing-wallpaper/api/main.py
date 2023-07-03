#!/usr/bin/env python
# -*- coding: utf-8 -*-


import json
import os

import bing_image


def main():
    country = ['zh-CN','ja-JP','en-US']
    #country = ['fr-FR','de-DE','es-ES','en-GB','it-IT','pt-BR']
    number = ['0','1','2','3','4','5','6','7']
    for i in country:
        for n in number:
            data = bing_image.get_json_data(i,n)
            date = data.get('end_date')

            dirname = i.lower() + '/' + date[0:4] + '/' + date[4:6]
            name = date[6:8]
            filename = dirname + '/' + name + '.json'
            os.makedirs(dirname, exist_ok=True)

            with open(filename, 'w') as f:
                f.write(json.dumps(data, ensure_ascii=False, indent=2))


if __name__ == '__main__':
    main()
