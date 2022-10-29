from vm_booking_api.app import db
from .conftest import app


def test_get_vms(client, new_vm):
    with app.app_context():
        db.session.add(new_vm)
        db.session.commit()

        rv = client.get("api/vms")

        assert rv.status_code == 200
        assert rv.json == {"vms": [new_vm.to_dict()]}


def test_get_vm(client, new_vm):
    with app.app_context():
        db.session.add(new_vm)
        db.session.commit()

        rv = client.get(f"api/vms/{new_vm.id}")

        assert rv.status_code == 200
        assert rv.json == {"vm": new_vm.to_dict()}


def test_get_unknown_vm(client):
    rv = client.get("api/vms/unknown_id")

    assert rv.status_code == 404


def test_create_vm(client, new_vm):
    rv = client.post("/api/vms", json=new_vm.to_dict())
    assert rv.json == {"vm": new_vm.to_dict()}


def test_create_vm_missing_name(client, new_vm):
    new_vm_dict = new_vm.to_dict()
    new_vm_dict.pop("name", None)

    rv = client.post("/api/vms", json=new_vm_dict)

    assert rv.status_code == 400


def test_create_vm_missing_ip(client, new_vm):
    new_vm_dict = new_vm.to_dict()
    new_vm_dict.pop("ip", None)

    rv = client.post("/api/vms", json=new_vm_dict)

    assert rv.status_code == 400


def test_create_vm_missing_user_id(client, new_vm):
    new_vm_dict = new_vm.to_dict()
    new_vm_dict.pop("user_id", None)

    rv = client.post("/api/vms", json=new_vm_dict)

    assert rv.status_code == 400


def test_create_vm_invalid_reservation_start_format(client, new_vm):
    new_vm.reservation_start = "2010/22/2"
    new_vm_dict = new_vm.to_dict()

    rv = client.post("/api/vms", json=new_vm_dict)

    assert rv.status_code == 400


def test_create_vm_invalid_reservation_end_format(client, new_vm):
    new_vm.reservation_end = "2010/22/2"
    new_vm_dict = new_vm.to_dict()

    rv = client.post("/api/vms", json=new_vm_dict)

    assert rv.status_code == 400


def test_update_vm(client, new_vm):
    with app.app_context():
        db.session.add(new_vm)
        db.session.commit()

        new_desc = "new desc"
        rv = client.put(f"api/vms/{new_vm.id}", json={"description": new_desc})

        new_vm.description = new_desc
        assert rv.json == {"vm": new_vm.to_dict()}


def test_update_unknown_vm(client):
    rv = client.put("api/vms/unknown_id")

    assert rv.status_code == 404


def test_delete_vm(client, new_vm):
    with app.app_context():
        db.session.add(new_vm)
        db.session.commit()

        vm_dict = new_vm.to_dict()

        rv = client.delete(f"api/vms/{new_vm.id}")

        assert rv.json == {"vm": vm_dict}


def test_delete_unknown_vm(client):
    rv = client.delete("api/vms/unknown_id")

    assert rv.status_code == 404


def test_get_vm_use(client, new_user, new_vm):
    with app.app_context():
        db.session.add(new_user)
        db.session.add(new_vm)
        db.session.commit()

        rv = client.get(f"/api/users/{new_user.username}/vm-use")

        assert rv.json == {
            "user": new_user.to_dict(only=("username", "email", "vms", "-vms.user_id"))
        }


def test_get_vm_use_unknown_user(client, new_vm):
    with app.app_context():
        db.session.add(new_vm)
        db.session.commit()

        rv = client.get("/api/users/unknown_username/vm-use")

        assert rv.status_code == 404
