ElevatedButton.icon(
  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WithdrawScreen())),
  icon: Icon(Icons.money),
  label: Text('Withdraw to M-Pesa'),
  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
)