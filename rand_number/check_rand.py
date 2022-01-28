import json

with open('rand.json') as json_file:
    data = json.load(json_file)

    print("\ncheck rdr....")
    for key in data['rdr']:
        print(key)

    print("\ncheck p2p....")
    # for key in data['p2p_controlled']:
    #     print(key)
    # for key in data['p2p_controlled']["1"]:
    #     print(key)
