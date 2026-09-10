import streamlit as st
from PIL import Image
import pandas as pd
import uuid
from datetime import datetime
import os

# Page Config
st.set_page_config(
    page_title="Explainable AI for Diabetic Retinopathy Screening",
    page_icon="👁️",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS
st.markdown("""
<style>
    .main-title {
        font-size: 2.4rem !important;
        font-weight: 800;
        color: #1f77b4;
        margin-bottom: 0.3rem;
    }
    .sub-title {
        font-size: 1.2rem !important;
        color: #444;
        margin-bottom: 1.5rem;
    }
</style>
""", unsafe_allow_html=True)

# Paths
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
INPUT_DIR = os.path.join(BASE_DIR, "..", "temp_input")
OUTPUT_DIR = os.path.join(BASE_DIR, "..", "temp_output")
HISTORY_FILE = os.path.join(BASE_DIR, "patient_history.csv")

os.makedirs(INPUT_DIR, exist_ok=True)
os.makedirs(OUTPUT_DIR, exist_ok=True)

if not os.path.exists(HISTORY_FILE):
    df = pd.DataFrame(columns=["PatientID", "Name", "Date", "Grade", "Confidence", "Quality"])
    df.to_csv(HISTORY_FILE, index=False)

# Sidebar
with st.sidebar:
    st.title("RetinaCare AI")
    st.markdown("---")
    st.subheader("System Modules")
    st.markdown("""
    - Image Quality Assessment  
    - CLAHE Enhancement  
    - EfficientNet-B0 Classification  
    - Grad-CAM Explainability  
    """)
    st.markdown("---")
    st.info("Rural Primary Healthcare Screening System")

# Main Title
st.markdown('<p class="main-title">Explainable AI for Diabetic Retinopathy Screening</p>', unsafe_allow_html=True)
st.markdown('<p class="sub-title">Rural India | MATLAB Powered Pipeline</p>', unsafe_allow_html=True)
st.divider()

# Session state init
if "image_saved" not in st.session_state:
    st.session_state.image_saved = False
if "results_loaded" not in st.session_state:
    st.session_state.results_loaded = False

# Tabs
tab1, tab2 = st.tabs(["New Screening", "Patient History"])

# ==================== TAB 1 ====================
with tab1:
    st.subheader("Patient Details")
    
    patient_name = st.text_input("Patient Name")
    
    if patient_name.strip() != "":
        if "patient_id" not in st.session_state or st.session_state.get("last_name") != patient_name:
            st.session_state.patient_id = "PID-" + str(uuid.uuid4())[:8].upper()
            st.session_state.last_name = patient_name
        current_id = st.session_state.patient_id
        st.success(f"Patient ID: **{current_id}**")
    else:
        current_id = None
        st.info("Enter Patient Name to generate Patient ID")
    
    st.subheader("Upload Fundus Image")
    uploaded_file = st.file_uploader("Upload a retinal fundus image (PNG / JPG)", type=["png", "jpg", "jpeg"])
    
    if uploaded_file is not None:
        image = Image.open(uploaded_file)
        
        col_img, col_info = st.columns([1, 2])
        
        with col_img:
            st.image(image, caption="Uploaded Image", use_container_width=True)
        
        with col_info:
            st.success("Image uploaded successfully!")
            st.write(f"**File:** {uploaded_file.name}")
            
            if st.button("1. Save Image for MATLAB", type="primary", use_container_width=True):
                # Clear previous
                for f in os.listdir(INPUT_DIR):
                    os.remove(os.path.join(INPUT_DIR, f))
                for f in os.listdir(OUTPUT_DIR):
                    os.remove(os.path.join(OUTPUT_DIR, f))
                
                input_path = os.path.join(INPUT_DIR, "input.png")
                image.save(input_path)
                st.session_state.image_saved = True
                st.session_state.results_loaded = False
                st.success("Image saved to temp_input. Now run processImage in MATLAB.")
        
        # Show next step only after image is saved
        if st.session_state.image_saved:
            st.info("Now open MATLAB → run `processImage` → then click the button below.")
            
            if st.button("2. Load Results from MATLAB", type="primary", use_container_width=True):
                results_file = os.path.join(OUTPUT_DIR, "results.txt")
                enhanced_path = os.path.join(OUTPUT_DIR, "enhanced.png")
                gradcam_path = os.path.join(OUTPUT_DIR, "gradcam.png")
                
                if not os.path.exists(results_file):
                    st.error("Results not found. Please run processImage in MATLAB first.")
                else:
                    with open(results_file, "r") as f:
                        lines = f.readlines()
                        grade = lines[0].strip()
                        confidence = lines[1].strip() + "%"
                        quality = lines[2].strip()
                    
                    st.session_state.results_loaded = True
                    st.session_state.grade = grade
                    st.session_state.confidence = confidence
                    st.session_state.quality = quality
                    st.session_state.enhanced_path = enhanced_path
                    st.session_state.gradcam_path = gradcam_path
                    st.session_state.original_image = image
        
        # Show results if loaded
        if st.session_state.results_loaded:
            st.success("Pipeline executed successfully!")
            
            st.subheader("Pipeline Results")
            c1, c2, c3 = st.columns(3)
            
            with c1:
                st.markdown("**Original Image**")
                st.image(st.session_state.original_image, use_container_width=True)
            with c2:
                st.markdown("**Enhanced (CLAHE)**")
                if os.path.exists(st.session_state.enhanced_path):
                    st.image(st.session_state.enhanced_path, use_container_width=True)
            with c3:
                st.markdown("**Grad-CAM Heatmap**")
                if os.path.exists(st.session_state.gradcam_path):
                    st.image(st.session_state.gradcam_path, use_container_width=True)
            
            st.markdown("---")
            st.subheader("Screening Outcome")
            
            m1, m2, m3, m4 = st.columns(4)
            m1.metric("Predicted Grade", st.session_state.grade)
            m2.metric("Confidence", st.session_state.confidence)
            m3.metric("Quality Status", st.session_state.quality)
            m4.metric("Referable DR", "Yes" if st.session_state.grade in ["Moderate", "Severe", "Proliferate_DR"] else "No")
            
            with st.expander("View Clinical Notes", expanded=True):
                st.write(f"""
                - **Quality Assessment:** {st.session_state.quality}  
                - **Model Focus:** Important regions highlighted by Grad-CAM  
                - **Recommendation:** {"Refer to ophthalmologist" if st.session_state.grade != "No_DR" else "Routine follow-up"}
                """)
            
            # Save to history
            if current_id and patient_name.strip() != "":
                new_record = {
                    "PatientID": current_id,
                    "Name": patient_name,
                    "Date": datetime.now().strftime("%Y-%m-%d %H:%M"),
                    "Grade": st.session_state.grade,
                    "Confidence": st.session_state.confidence,
                    "Quality": st.session_state.quality
                }
                
                df = pd.read_csv(HISTORY_FILE)
                df = pd.concat([df, pd.DataFrame([new_record])], ignore_index=True)
                df.to_csv(HISTORY_FILE, index=False)
                
                st.success(f"Result saved for **{patient_name}** ({current_id})")

# ==================== TAB 2 ====================
with tab2:
    st.subheader("Patient Screening History")
    
    df = pd.read_csv(HISTORY_FILE)
    
    if df.empty:
        st.info("No records found yet.")
    else:
        st.dataframe(df, use_container_width=True)
        
        st.download_button(
            "Download History as CSV",
            df.to_csv(index=False),
            file_name="patient_history.csv",
            mime="text/csv"
        )