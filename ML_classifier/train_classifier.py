# ML_classifier/train_classifier.py
import csv
import pickle
from sklearn.tree import DecisionTreeClassifier
from sklearn.model_selection import cross_val_score
import numpy as np

# Load training data
X, y = [], []
with open("ML_classifier/training_data.csv") as f:
    for row in csv.DictReader(f):
        X.append([
            int(row["query_type_enc"]),
            int(row["has_country"]),
            int(row["has_city"]),
            int(row["has_bbox"]),
            int(row["payload_keys"]),
        ])
        y.append(int(row["label"]))

# Train Decision Tree (simple, explainable, no heavy dependencies)
clf = DecisionTreeClassifier(max_depth=4, random_state=42)
clf.fit(X, y)

# Cross-validate
scores = cross_val_score(clf, X, y, cv=3)
print(f"[TRAIN] Cross-val accuracy: {scores.mean():.2f} (+/- {scores.std():.2f})")

# Save model
with open("ML_classifier/query_classifier.pkl", "wb") as f:
    pickle.dump(clf, f)

print("[TRAIN] Model saved to ML_classifier/query_classifier.pkl")

# Print decision rules
from sklearn.tree import export_text
print("\n[TRAIN] Decision rules:")
print(export_text(clf, feature_names=["query_type_enc","has_country","has_city","has_bbox","payload_keys"]))