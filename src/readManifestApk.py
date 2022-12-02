#Predict
from androguard.core.bytecodes.apk import APK
print('heehe')
def predict(apk):
  vector = {}
  a = APK(apk)
  perm = a.get_permissions()
  # print(perm)
  for d in perms:
    if d in perm:
      vector[d]=1
    else:
      vector[d]=0
  input = [ v for v in vector.values() ]
  json_file = open('malwaredetection.json', 'r')
  loaded_model_json = json_file.read()
  json_file.close()
  loaded_model = model_from_json(loaded_model_json)
  # load weights into new model
  # loaded_model.load_weights("model.h5")
  return loaded_model.predict(input)
  
  # print(tree.predict([input]))
  # output = tree.predict([input])

# predict('Ransomware/PornDroid/1c53e2c34d1219a2fae8fcf8ec872ac8.apk')
# predict('dataset/benign/a.envisionmobile.caa.apk')