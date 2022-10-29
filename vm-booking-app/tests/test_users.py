from vm_booking_api.app import db, User
from .conftest import app


def test_index(client):
    rv = client.get("/")
    assert rv.status_code == 200
    assert b"API is working" in rv.data


def test_healthy(client):
    rv = client.get("/healthy")
    assert rv.status_code == 200
    assert b"API is healthy" in rv.data


def test_get_users(client, new_user):
    with app.app_context():
        db.session.add(new_user)
        db.session.commit()

        rv = client.get("/api/users")
        assert rv.status_code == 200
        assert rv.json == {"users": [new_user.to_dict()]}


def test_get_user(client, new_user):
    with app.app_context():
        db.session.add(new_user)
        db.session.commit()

        rv = client.get(f"/api/users/{new_user.username}")

        assert rv.json == {"user": new_user.to_dict()}


def test_get_unknown_user(client):
    rv = client.get("/api/users/unknown_username")

    assert rv.status_code == 404


def test_create_user(client, new_user):
    rv = client.post("/api/users", json=new_user.to_dict())

    assert rv.json == {"user": new_user.to_dict()}


def test_create_user_missing_email(client, new_user):
    new_user_dict = new_user.to_dict()
    new_user_dict.pop("email", None)

    rv = client.post("/api/users", json=new_user_dict)

    assert rv.status_code == 400


def test_create_user_missing_username(client, new_user):
    new_user_dict = new_user.to_dict()
    new_user_dict.pop("username", None)

    rv = client.post("/api/users", json=new_user_dict)

    assert rv.status_code == 400


def test_create_user_duplicate_email_or_username(client, new_user):
    with app.app_context():
        db.session.add(new_user)
        db.session.commit()

        rv = client.post("/api/users", json=new_user.to_dict())

        assert rv.status_code == 400


def test_delete_user(client, new_user):
    with app.app_context():
        db.session.add(new_user)
        db.session.commit()

        rv = client.delete(f"/api/users/{new_user.username}")

        assert rv.json == {"user": new_user.to_dict()}


def test_delete_unknown_user(client):
    rv = client.delete("/api/users/unknown_username")

    assert rv.status_code == 404


def test_update_user(client, new_user):
    with app.app_context():
        db.session.add(new_user)
        db.session.commit()

        new_email = "new_test_user4@gmail.com"
        rv = client.put(f"/api/users/{new_user.username}", json={"email": new_email})

        new_user.email = new_email

        assert rv.json == {"user": new_user.to_dict()}


def test_update_user_with_existing_username(client, new_user):
    with app.app_context():
        new_user2 = User(id=2, email="test_user2@gmail.com", username="test_user2")
        db.session.add(new_user)
        db.session.add(new_user2)
        db.session.commit()

        new_email = new_user2.email

        rv = client.put(f"/api/users/{new_user.username}", json={"email": new_email})

        assert rv.status_code == 400


def test_update_unknown_user(client):
    rv = client.put("/api/users/unknown_username")

    assert rv.status_code == 404
