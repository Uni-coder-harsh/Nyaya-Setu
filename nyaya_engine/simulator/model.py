from mesa import Model
from mesa.datacollection import DataCollector
from agents import Disputant

class NyayaMesaModel(Model):
    def __init__(self, base_value):
        super().__init__()
        self.proposed_settlement = base_value
        self.settled = False
        
        # Agents automatically get unique IDs from the Model in Mesa 3.0
        self.p = Disputant(self, "Plaintiff", base_value * 1.3)
        self.d = Disputant(self, "Defendant", base_value * 0.7)
        
        # Initialize DataCollector to track the 'heartbeat' of the negotiation
        self.datacollector = DataCollector(
            model_reporters={"Proposed_Settlement": "proposed_settlement"}
        )

    def step(self):
        # 1. Record the current state
        self.datacollector.collect(self)
        
        # 2. Let agents "think" and decide if they are satisfied
        self.agents.shuffle_do("step")
        
        # 3. Mediator updates the proposal (Moving toward the middle)
        self.proposed_settlement = (self.p.valuation + self.d.valuation) / 2
        
        # 4. Negotiation convergence logic
        self.p.valuation -= (self.p.valuation * self.p.concession_rate)
        self.d.valuation += (self.d.valuation * self.d.concession_rate)

        if self.p.settled and self.d.settled:
            self.settled = True
            self.running = False