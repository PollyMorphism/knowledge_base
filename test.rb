class BankAccount
  attr_accessor :balance

  def initialize(balance)
    @balance = balance
    @mutex = Mutex.new
  end

  def deposit(amount)
    new_balance = @balance + amount
    sleep(0.1)
    @balance = new_balance
  end
end

account = BankAccount.new(100)

t1 = Thread.new { account.deposit(50) }
t2 = Thread.new { account.deposit(70) }

t1.join
t2.join

puts "Final balance: #{account.balance}"
