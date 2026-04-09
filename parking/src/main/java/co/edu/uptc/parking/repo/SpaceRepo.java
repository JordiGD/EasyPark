package co.edu.uptc.parking.repo;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import co.edu.uptc.parking.entity.Space;

@Repository
public interface SpaceRepo extends JpaRepository<Space, Long> {
    List<Space> findByParkingId(Long parkingId);
}
