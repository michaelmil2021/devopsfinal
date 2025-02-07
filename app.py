from flask import Flask

app=Flask(__name__)

@app.route ('/')
def greetme():
    return "hello devops"

@app.route ('/page1')
def page1():
    return "welcome to page1"

if __name__=='__main__':
    app.run(host='0.0.0.0',port=5000)