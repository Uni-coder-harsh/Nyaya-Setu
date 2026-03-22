from mesa import Agent

class Disputant(Agent):
    def __init__(self, model, role, initial_valuation):
        # No need to pass unique_id; Mesa 3.0 assigns it automatically
        super().__init__(model)
        self.role = role
        self.valuation = initial_valuation
        self.concession_rate = 0.05
        self.settled = False

    def step(self):
        target = self.model.proposed_settlement
        # Acceptance threshold (8%)
        if abs(target - self.valuation) < (self.valuation * 0.08):
            self.settled = True