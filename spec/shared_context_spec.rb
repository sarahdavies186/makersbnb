shared_context "doubles setup" do

  # shared_context allows me to have a sort of a setup for my tests,
  # avoiding repetitions. In fact, this is where I put all my doubles,
  # so I don't have to create one, everytime I need one.

  # A let keyword is like a before block but it's lazy load,
  # meaning it runs only when it's called which is more efficient in terms of performance.
  # The variable name is a symbol when it's declared but then can be use as a regular variable
  # without the colon. I think inside the block can be anything. 
  # Up until now I mainly use it to declare doubles.

  # I placed in a different page because
  # it tends to be long. To use it, 
  # I will put 'include_context "doubles setup"' before my example tests.

  # Mocks of Room objects
  let(:roomRepo) { double :RoomRepo }
  let(:room1) { double :Room, {
    id: 1,
    name: 'Changs Palace', 
    description: 'A modern apartment in the heart of the city',
    price: '300',
    available_from: '2023-05-01',
    available_to: '2023-05-03',
    user_id: 1
     }}
  let(:room2) { double :Room, { 
    id: 2,
    room: 2,
    name: 'Sarahs Sunset Side', 
    description: 'A beautiful house with ocean views',
    price: '200',
    available_from: '2023-05-02',
    available_to: '2023-05-03',
    user_id: 2
     }}
  let(:room3) { double :Room, { 
    id: 3,
    name: 'Kons Gaff', 
    description: 'Studio apartment, no toilet, naked cat included',
    price: '20',
    available_from: '2023-05-02',
    available_to: '2023-05-05',
    user_id: 3
     }}
  let(:room4) { double :Room, { 
    id: 4,
    name: 'Monmons Cozy Castle', 
    description: 'A charming castle in the countryside',
    price: '250',
    available_from: '2023-05-04',
    available_to: '2023-05-05',
    user_id: 4
     }}
  let(:room5) { double :Room, { 
    id: 5,
    name: 'Destans Polski Sklep', 
    description: 'You can stay here and put a little shift in, stock some shelves too',
    price: '250',
    available_from: '2023-05-01',
    available_to: '2023-05-04',
    user_id: 5
     }}
  let(:room6) { double :Room, {
    id: 6,
    name: 'Manhattan Appartment', 
    description: 'Lovely appartment near Times Square',
    price: '300',
    available_from: '2023-05-01',
    available_to: '2023-05-03',
    user_id: 1
     }}
  let(:room7) { double :Room, {
    id: 6,
    name: 'Manhattan Appartment', 
    description: 'Lovely appartment near Times Square',
    price: '300',
    available_from: '2023-05-06',
    available_to: '2023-05-08',
    user_id: 1
     }}
end