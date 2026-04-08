package co.edu.uptc.parking.repo;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import co.edu.uptc.parking.entity.Parking;

@Repository
public interface ParkingRepo extends JpaRepository<Parking, Long> {
    
}
