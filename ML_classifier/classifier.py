# ML_classifier/classifier.py
import pickle
import os

MODEL_PATH = os.path.join(os.path.dirname(__file__), "query_classifier.pkl")

TYPE_MAP = {"by_city": 0, "by_country": 1, "by_bbox": 2, "default": 3}

# Load model once at import time
with open(MODEL_PATH, "rb") as f:
    _clf = pickle.load(f)

def extract_features(req_type: str, payload: dict) -> list:
    """Convert a query request into a feature vector."""
    return [
        TYPE_MAP.get(req_type, 3),          # query_type_enc
        1 if "country"  in payload else 0,  # has_country
        1 if "city"     in payload else 0,  # has_city
        1 if "lat_min"  in payload else 0,  # has_bbox
        len(payload),                        # payload_keys
    ]

def classify(req_type: str, payload: dict) -> str:
    """Returns 'heavy' or 'light'."""
    features = extract_features(req_type, payload)
    prediction = _clf.predict([features])[0]
    return "heavy" if prediction == 1 else "light"