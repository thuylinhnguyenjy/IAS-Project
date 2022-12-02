from flask import Flask, request, jsonify, redirect, url_for, flash, session, app
import werkzeug
from androguard.core.bytecodes.apk import APK
import pickle 
import sklearn

app = Flask(__name__)

@app.route('/')
def home():
  return "IAS DEMO"

@app.route('/upload', methods=['POST'])
def upload():
    if (request.method == "POST"):
        apk = request.files['apk']
        filename = werkzeug.utils.secure_filename(apk.filename)
        apk.save("./uploaded_apk/" + filename)
        return jsonify({
            "message": "Apk Upload Sucessfully",
            "filename": filename
        })
    return jsonify({
            "message": "Apk Upload Not Sucessfully"
        })

@app.route('/predict', methods=['GET'])
def predict():
  vector = {}
  a = APK(r'./uploaded_apk/a.envisionmobile.caa.apk')
  perm = a.get_permissions()
  perms = loadPermission()

  for d in perms:
    if d in perm:
      vector[d]=1
    else:
      vector[d]=0
  input = [ v for v in vector.values() ]
  with open('./model_pkl' , 'rb') as f:
    lr = pickle.load(f)
  res = lr.predict([input])
  
  return str(res[0])

def loadPermission():
  default = open('./DefaultPermList.txt','r').readlines()
  perms = [s.rstrip('\n') for s in default]
  return perms

if __name__ == '__main__':
  app.run(host="192.168.137.1", port=5000, debug = True)