import pandas as pd
from model import NyayaMesaModel

model = NyayaMesaModel(10000)

for i in range(20):
    model.step()
    if not model.running:
        break


model_data = model.datacollector.get_model_vars_dataframe()
model_data.to_csv("simulation_results.csv")

print("✅ Data exported to simulation_results.csv")
print(model_data.tail()) # Show the last few rounds