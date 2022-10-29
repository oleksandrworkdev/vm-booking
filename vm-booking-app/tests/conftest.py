import pytest
from datetime import datetime

from vm_booking_api.constants import DATE_FORMAT
from vm_booking_api.models import db, User, Vm
from vm_booking_api import create_app

app = create_app()
app.config["TESTING"] = True
app.testing = True

# This creates an in-memory sqlite db
# See https://martin-thoma.com/sql-connection-strings/
app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite://"
app.config["APP_VERSION"] = "0.1"


@pytest.fixture
def client():
    client = app.test_client()
    with app.app_context():
        db.create_all()
    yield client
    with app.app_context():
        db.drop_all()


@pytest.fixture()
def new_user():
    user = User(id=1, email="test_user1@gmail.com", username="test_user1")
    return user


@pytest.fixture()
def new_vm():
    rs = datetime.strptime("20/10/2020", DATE_FORMAT)
    re = datetime.strptime("25/10/2020", DATE_FORMAT)
    vm = Vm(
        id=1,
        name="VM1",
        ip="10.0.0.1",
        user_id=1,
        status="running",
        reservation_start=rs,
        reservation_end=re,
        description="test",
    )
    return vm
