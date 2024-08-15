import pyrebase
from firebase_admin import credentials, storage, initialize_app

#
from Value import Value
import os
from datetime import datetime
import json

class Firebase:
    def __init__(self):
        #khoi tao firebase
        self.Certificate = 'camera-e454d-firebase-adminsdk-5wwis-e69481553d.json'
        self.dbURL = 'https://camera-e454d-default-rtdb.firebaseio.com'
        self.stBucket = 'camera-e454d.appspot.com'
        self.autDomain = "projectId.firebaseapp.com"

        config = {
            "apiKey": self.Certificate,
            "authDomain": self.autDomain,
            "databaseURL":self.dbURL,
            "storageBucket": self.stBucket
        }

        cred = credentials.Certificate(self.Certificate)
        initialize_app(cred, {
            "storageBucket": self.stBucket
        })

        self.firebase = pyrebase.initialize_app(config)
        self.db = self.firebase.database()
        self.bucket = storage.bucket()

    # danh sách model có trên server
    def get_models(self): 
        return self.firebase.database().child(Value.path_model.value).get().val()  

    # remove model
    def remove_models(self, model):
        #remove in realtime
        self.firebase.database().child(Value.path_model.value).child(model).remove()
        #remove in storage
        self.bucket.delete_blob(Value.path_model.value + model)
        
        
    #format đường dẫn thành name
    def get_file_name(self, path):
        return (path.split('/')[-1]).split('.')[0]
    
    # tải model với filename lên server
    def upload_model(self, filename):
        if filename == "" : 
            return False, ""
        self.bucket = storage.bucket()

        time = datetime.now()  # thời gian hiện tại
        name = self.get_file_name(filename) # format name VD: C:/Path/models/yolov8.zip => yolov8.zip
        blob = self.bucket.blob(Value.path_model.value+name)  # điều chỉnh đường dẫn lưu trên storage Server firebase
        blob.upload_from_filename(filename)  #upload file lên storage server firebase
        size = os.path.getsize(filename) #size của file upload  
        
        # Tạo thông tin
        data = {        
            'model': name,
            'time': time.strftime("%y-%m-%d %H:%M"),
            'size': size,
        }

        # upload data lên realtime với id là name
        self.db.child(Value.path_model.value).child(str(name)).set(data=data)    
        
        return True, name