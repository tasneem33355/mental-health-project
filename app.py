import streamlit as st
import numpy as np
import pickle
from tensorflow.keras.models import load_model

# ================== PAGE STYLE ==================

st.set_page_config(
    page_title="Mental Health AI",
    page_icon="🧠",
    layout="wide"
)

st.markdown("""
<style>

.stApp {
    background: linear-gradient(to right, #667eea, #764ba2);
    color: white;
}

h1 {
    text-align: center;
    color: white;
    font-size: 40px;
}

div.stButton > button {
    background-color: #00c6ff;
    color: white;
    font-size: 20px;
    border-radius: 12px;
    height: 60px;
    width: 200px;
}

div.stSlider {
    background-color: rgba(255,255,255,0.1);
    padding:10px;
    border-radius:10px;
}

.resultBox {
    background-color:white;
    color:black;
    padding:20px;
    border-radius:15px;
    box-shadow:0px 5px 15px rgba(0,0,0,0.3);
    text-align:center;
    font-size:20px;
}

</style>
""", unsafe_allow_html=True)


# ================== LOAD MODEL ==================

model = load_model("mental_model.h5", compile=False)
scaler = pickle.load(open("scaler.pkl","rb"))

# ================== QUESTIONS ==================

questions = [

"I found it hard to wind down",
"I was aware of dryness of my mouth",
"I couldn't seem to experience any positive feeling at all",
"I experienced breathing difficulty",
"I found it difficult to work up the initiative to do things",
"I tended to over-react to situations",
"I experienced trembling",
"I felt that I was using a lot of nervous energy",
"I was worried about situations in which I might panic",
"I felt that I had nothing to look forward to",
"I found myself getting agitated",
"I found it difficult to relax",
"I felt down-hearted and blue",
"I was intolerant of anything that kept me from getting on",
"I felt I was close to panic",
"I was unable to become enthusiastic",
"I felt I wasn't worth much as a person",
"I felt that I was rather touchy",
"I was aware of the action of my heart",
"I felt scared without any good reason",
"I felt that life was meaningless",

"I found it hard to calm down",
"I felt nervous",
"I felt sad and depressed",
"I found myself getting impatient",
"I felt that I was rather emotional",
"I felt restless",
"I had difficulty concentrating",
"I felt lonely",
"I found it difficult to relax",
"I felt hopeless",
"I felt worried about many things",
"I felt that I had no energy",
"I felt tense",
"I felt tired for no reason",
"I felt uneasy",
"I felt worthless",
"I felt anxious",
"I felt discouraged",
"I felt stressed",
"I felt overwhelmed",
"I felt emotionally exhausted"

]

# ================== TITLE ==================

st.title("🧠 Mental Health AI Prediction System")

st.write("### Answer the questions below")

# ================== SLIDERS ==================

answers = []

for i, q in enumerate(questions):
    val = st.slider(q,0,4,0,key=i)
    answers.append(val)


# ================== PREDICTION ==================

if st.button("Predict Mental Health"):

    data = np.array(answers).reshape(1,-1)

    data = scaler.transform(data)

    pred = model.predict(data)[0]

    # تحويل إلى نسبة مئوية
    depression = int(pred[0]*100)
    anxiety = int(pred[1]*100)
    stress = int(pred[2]*100)

    st.write("")

    col1,col2,col3 = st.columns(3)

    col1.markdown(f"""
    <div class="resultBox">
    <h2>Depression</h2>
    <h1>{depression}%</h1>
    </div>
    """, unsafe_allow_html=True)

    col2.markdown(f"""
    <div class="resultBox">
    <h2>Anxiety</h2>
    <h1>{anxiety}%</h1>
    </div>
    """, unsafe_allow_html=True)

    col3.markdown(f"""
    <div class="resultBox">
    <h2>Stress</h2>
    <h1>{stress}%</h1>
    </div>
    """, unsafe_allow_html=True)

    st.write("")

    st.success("Prediction Completed Successfully")