import tkinter as tk
from tkinter import messagebox 
from tkinter import ttk 
from tkinter import filedialog

import datetime
import io
from PIL import Image, ImageTk
import math
import json
from datetime import datetime

#
from Value import Value
from Firebase import Firebase 
import icons

class App(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title(Value.title.value)  
        self.width= self.winfo_screenwidth()               
        self.height= self.winfo_screenheight()               
        self.geometry("%dx%d" % (self.width, self.height))

        self.fbimage = None
        self.my_stream = None
        self.fb = Firebase()
        self.file_name = None

        self.download = False    

        #button upload
        self.btn_upload_file = tk.Button(self, text= icons.plus + " Upload", command=self.upload_file)
        self.btn_upload_file.grid(column=2, row=1, columnspan=1, padx = 5, sticky=tk.W)

        #button delete
        self.btn_delete = tk.Button(self, text= icons.wastebasket + "Delete", command=self.delete_file)
        self.btn_delete.grid(column=2, row=1, padx = 5)

        #label number
        self.lbl_number = tk.Label(self, text="Number: _")
        self.lbl_number.grid(column=2, row=2, rowspan=1 ,sticky = tk.W)

        #label number
        self.lbl_byte_stored = tk.Label(self, text="Byte stored: _ (MB)")
        self.lbl_byte_stored.grid(column=2, row=3, sticky = tk.W)

        #frame 
        frame = tk.Frame(self, relief=tk.SUNKEN)
        frame.grid(column=2, row=0, padx = 5,sticky=tk.NSEW)
        #List models : cấu trúc Treeview --- tkinter
        #khởi tạo columns: 4 cột
        columns=(1, 2, 3, 4)
        
        self.models = ttk.Treeview(frame, columns=columns, show='headings', height=10)
        self.models.heading(1, text="Number")
        self.models.column(1, width=50)
        self.models.heading(2, text="Name")
        self.models.heading(3, text="Size (MB)")
        self.models.heading(4, text="Datetime (yy-mm-dd hh:mm)")
        self.models.pack(side=tk.LEFT,  fill=tk.BOTH)

        #Scrollbar treeview
        sb = tk.Scrollbar(frame, orient=tk.VERTICAL)
        sb.pack(side=tk.RIGHT, fill=tk.Y)

        self.models.config(yscrollcommand=sb.set)
        sb.config(command=self.models.yview)

        #style treeview
        style = ttk.Style()
        style.theme_use("default")
        style.map("Treeview")

        #global

        self.cv_output_image_global= tk.Canvas(self, bg='white', bd=1, relief=tk.SUNKEN)
        self.cv_output_image_global.grid(column=1, row=0, rowspan=5)

        self.cv_input_image_global= tk.Canvas(self, bg='white', bd=1, relief=tk.SUNKEN)
        self.cv_input_image_global.grid(column=0, row=0, rowspan=5)

        tk.Label(self, text="Input global").grid(column=0,row=0, sticky=tk.NW)

        tk.Label(self, text="Output global").grid(column=1,row=0, sticky=tk.NW)

        #local 
        self.cv_output_image_local = tk.Canvas(self, bg='white', bd=1, relief=tk.SUNKEN)
        self.cv_output_image_local.grid(column=1, row=6, rowspan=5)

        self.cv_input_image_local = tk.Canvas(self, bg='white', bd=1, relief=tk.SUNKEN)
        self.cv_input_image_local.grid(column=0, row=6, rowspan=5)

        tk.Label(self, text="Input local").grid(column=0,row=6, sticky=tk.NW)

        tk.Label(self, text="Output local").grid(column=1,row=6, sticky=tk.NW)

        # Action
        tk.Label(self, text="Actions").grid(column=0,row=12, sticky=tk.NW)

        self.actions = tk.Text(self, height=10)
        self.actions.grid(column=0, row=13, columnspan=2, sticky=tk.NSEW)
        self.insert_action("Actions")
        self.actions['state'] = tk.DISABLED
        
        # khởi tạo đọc dữ liệu models
        self.setup_models()


    def insert_action(self, text):
        self.actions['state'] = tk.NORMAL

        time = datetime.now().strftime("---%y-%m-%d-%H-%M-%S: ")
        self.actions.insert(tk.END, time + text + '\n')
        self.actions['state'] = tk.DISABLED
    #delete model
    def delete_file(self):
        for index in self.models.selection(): # lấy index đã selected
            model = self.models.item(index)['values'][1]  # lấy column 1(Name) tại index
            if messagebox.askquestion('Delete model', 'Do you really want to delete [' + model + ']') =="yes":
                self.fb.remove_models(model)  #remove model
                #reset lại models
                self.insert_action("delete " + model)
                self.reset_models()


    #Đọc dữ liệu model từ server --> models
    def setup_models(self):
        number = 0
        total = 0
        for key, value in self.fb.get_models().items():
            number += 1
            size = math.ceil((value['size'] * 0.000001) *100)/100     
                # *0.000001 --> đổi sang MB
                # ceil *100/100 --> làm tròn chữ số thập phân thứ 2
            total += size
            model = value['model']
            time = value['time']
    
            values = (number, model, size, time)
            # chèn values vào models (chèn từng dòng)
            self.models.insert("", "end", values=values)
        
        self.lbl_number.config(text="Number: " + str(number))
        self.lbl_byte_stored.config(text="Byte stored: " + str(total) + " (MB)")

    def reset_models(self):
        self.models.delete(*self.models.get_children()) #clear all item in models
        self.update()

        self.setup_models()
    
    #Mở file từ máy
    def upload_file(self, event=None):
        if self.download:
            return
        
        # Mở hộp thoại thư mục
        filename = filedialog.askopenfilename()

        if filename != "":
            self.download = True
            self.btn_upload_file.config(text="Uploading...")
        # Gọi hàm upload model từ Firebase
        state, model = self.fb.upload_model(filename)
        if state:
            #reset lại models
            self.reset_models()
            self.btn_upload_file.config(text= icons.plus + " Upload")
            self.insert_action("upload " + model)
            self.download = False


#main
if __name__ == "__main__":
    app = App()
    app.mainloop()